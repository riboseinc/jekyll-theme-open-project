# Setting up the site with continuous delivery via Gitlab CI and AWS

This summarizes a simple CD setup with single branch (master) mapping
to production server.

## Results

After each push to master branch, the site will be built and deployed to S3,
updating live site under corresponding domain.

## Pre-requisites

Provided you have set up the Jekyll site based on README.

## Steps

Connect repository with your Jekyll site to Gitlab CI with configuration like this:

TBD

Choose the desired domain name for the site and take a note of it.

Set up an S3 bucket for the static site, naming it after full domain name.

Set up an Alias hosted zone in Route 53, mapping the domain name to S3 bucket
created earlier.

Test by making a change and pushing it to master branch.
