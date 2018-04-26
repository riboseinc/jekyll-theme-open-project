# Setting up the site with continuous delivery via Gitlab CI and AWS

This summarizes a simple CD setup with single branch (master) mapping
to production server, with auto-build static site served from S3 bucket.

## Results

After each push to master branch, the site will be built and deployed to S3,
updating live site under corresponding domain.

## Pre-requisites

Provided you have set up the Jekyll site based on README,
you own the domain you want to use to publish the site,
you have AWS account, you know how to use AWS web console,
and you have an Route 53 hosted zone associated with your domain.

## Steps

0. Choose the desired domain name for the site and take a note of it.

1. Set up an S3 bucket for the static site, naming it after full domain name.

Copy its ARN and take note of it.

Add public read permissions: since it’ll be used for website hosting,
everyone must be able to access it.

Add bucket policy like following (it is recommended to use S3 policy generator
provided by AWS to enable s3:GetObject for all objects in your bucket):

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

Test by making a change and pushing it to master branch.

## Troubleshooting

### Build: Gem not found

If build stage fails with an error about gem not found,
try updating CI build script, changing `bundle` to `bundle --full-index`.
This may be needed if you’re using the latest theme version which
was just recently published. --full-index will make build take longer,
it’s advised to get rid of it when theme dependency becomes stable.

### Deploy: Access denied

Ensure IAM group policy is correct. Bucket ARN should be correct,
and should have the form of "arn:aws:s3:::<your_bucket_ARN>/*"
where the closing `/*` is important.

## Further improvements

Currently this documentation doesn’t cover these,
but guides are availableelsewhere:

- You may want to have separate staging and production branches in your
CI configuration.

- You may want to put CloudFront in front of your S3-hosted site.
