# Setting up the site with continuous delivery via Gitlab CI and AWS

This summarizes a couple simple CD setup options
with single main repository branch getting automatically
built and deployed to a public AWS S3 bucket
and served through your chosen domain name.

## Outcome

After each push to the main branch, the site will be built and deployed to S3,
updating live site under corresponding domain.

## Option 1: GitHub + Rakefile + Travis CI + AWS S3

### Pre-requisites

Provided you have

* set up the Jekyll site based on README and have its source on GitHub
  in a repo connected to Travis CI,
* got the domain name you want to use to publish the site,
* got an AWS account and created a public S3 bucket
  named after the domain name
  with appropriate Route 53 and optionally CloudFront configuration
  to map the bucket to the domain
  (Option 2 in this document covers a basic S3 + Route 53 setup).

### Steps

0. Configure environment variables in repository settings on Travis CI:

   - AWS_ACCESS_KEY_ID
   - AWS_SECRET_ACCESS_KEY
   - AWS_REGION
   - CLOUDFRONT_DISTRIBUTION_ID
   - CLOUDFRONT_STAGING_DISTRIBUTION_ID
   - S3_BUCKET_NAME
   - S3_STAGING_BUCKET_NAME

1. Copy `travis.yml` and `Rakefile` from Open Project theme file tree
   into your Jekyll site repository root, and rename the copied
   `travis.yml` to `.travis.yml` (prepend a dot to filename).

2. Add new gems to your Gemfile for building & testing:

   ```
   gem "rake"
   gem "html-proofer", "= 3.9.2"
   ```

3. That’s it, site should build for you on the next push lest there’re
   issues preventing Jekyll build from succeeding
   (test it locally first; see README).

## Option 2: Gitlab CI + AWS S3

### Pre-requisites

Provided you have set up the Jekyll site based on README,
you own the domain you want to use to publish the site,
you have AWS account, you know how to use AWS web console,
and you have an Route 53 hosted zone associated with your domain.

### Steps

0. Choose the desired domain name for the site and take a note of it.

1. Set up an S3 bucket for the static site, naming it after full domain name,
   and configure as follows:

   - Add public read permissions: since it’ll be used for website hosting,
     everyone must be able to access it.

   - Enable static website hosting in bucket settings,
     set index document path to index.html.

   - Add bucket policy like below (it is recommended to use S3 policy generator
     provided by AWS; the goal is to enable anyone to s3:GetObject
     on any object inside the bucket):

      ```json
      {
        "Id": "PolicyNNNNNNNNNNNNN",
        "Version": "2012-10-17",
        "Statement": [
          {
            "Sid": "StmtNNNNNNNNNNNNN",
            "Action": [
              "s3:GetObject"
            ],
            "Effect": "Allow",
            "Resource": "<your_bucket_ARN>/*",
            "Principal": "*"
          }
        ]
      }
      ```

    Take note of bucket’s ARN.

    Note: Never use the created bucket for storing anything sensitive.
    All contents will be visible to the entire Internet.

2. Add Alias record to your chosen domain’s hosted zone in Route 53,
   and select the S3 bucket as the target.

3. Create an IAM group, don’t assign any managed policies.
   This group will be used to facilitate CD updating bucket contents after each
   automatic site build.

4. To the group, attach an inline policy that looks like below,
   giving s3:PutObject permission on the contents of the bucket you created.
   
   You are advised to use AWS console inline policy wizard instead of
   manually entering this.  Note that you’ll need your bucket’s ARN.
   
   ```json
   {
       "Version": "2012-10-17",
       "Statement": [
           {
               "Sid": "StmtNNNNNNNNNNNNN",
               "Effect": "Allow",
               "Action": [
                   "s3:PutObject"
               ],
               "Resource": [
                   "<your_bucket_ARN>/*"
               ]
           }
       ]
   }
   ```

5. Create an IAM user in that group. Enable programmatic access (AWS API).
   Copy key and secret—this will be used during deployment.

6. Connect repository with your Jekyll site to Gitlab CI with configuration like this:

   ```yaml
   stages:
   - build
   - deploy
   
   build:
     stage: build
     image: ruby:2.4.4
     before_script:

     # Add SSH key to enable site build pull from repos.
     # You may be able to omit this if you specify HTTPS URLs for Git repos
     # (e.g., open project’s site.git_repo_url frontmatter variable).
     - 'which ssh-agent || ( apt-get update -y && apt-get install openssh-client -y )'
     - eval $(ssh-agent -s)
     - echo "$SSH_PRIVATE_KEY" | tr -d '\r' | ssh-add - > /dev/null
     - mkdir -p ~/.ssh
     - chmod 700 ~/.ssh

     - gem install jekyll bundler
     - bundle
     script:
     - bundle exec jekyll build
     artifacts:
       paths:
       - _site/
   
   deploy:
     stage: deploy
     image: python:latest
     before_script:
     - pip install awscli
     script:
     - aws s3 cp _site/ s3://$S3_BUCKET_NAME/ --recursive
     after_script:
     - rm -r _site
   ```

7. Add following secret variables to your Gitlab CI configuration:

   - AWS_ACCESS_KEY_ID: your IAM user’s API key ID
   - AWS_DEFAULT_REGION: region chosen when creating S3 bucket
   - AWS_SECRET_ACCESS_KEY: your IAM user’s API key secret
   - S3_BUCKET_NAME: name of S3 bucket
   - SSH_PRIVATE_KEY: private key of GitHub user who’s authorized to clone
     requisite source repositories

8. Test by making a change and pushing it to the main branch.

### Troubleshooting

#### Build: Gem not found

If build stage fails with an error about gem not found,
try updating CI build script, changing `bundle` to `bundle --full-index`.
This may be needed if you’re using the latest theme version which
was just recently published. --full-index will make build take longer,
it’s advised to get rid of it when theme dependency becomes stable.

#### Deploy: Access denied

Ensure IAM group policy is correct. Bucket ARN should be correct,
and should have the form of "arn:aws:s3:::<your_bucket_ARN>/*"
where the closing `/*` is important.

### Further improvements

- In the long run it is recommended to avoid maintaining two separate copies
  of data (e.g., same project data for project site, and one for parent hub site,
  or reposting posts from project site blogs into hub blog).
  
  Ideally, during static site build the automation would pull relevant data
  from a centralized or distributed source and place it as needed
  inside Jekyll site structure before executing `jekyll build`.

Common items that this documentation doesn’t cover,
but guides are available elsewhere:

- You may want to have separate staging and production branches in your
  CI configuration.

- You may want to put CloudFront in front of your S3-hosted site.
