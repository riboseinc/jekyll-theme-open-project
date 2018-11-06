require 'html-proofer'

$sourceDir = "./source"
$outputDir = "./output"
$testOpts = {
  # Ignore errors "linking to internal hash # that does not exist"
  :url_ignore => ["#"],
  # Allow empty alt tags (e.g. alt="") as these represent presentational images
  :empty_alt_ignore => true
}

hostname = ENV['SITE_HOSTNAME']
region = ENV['SITE_REGION']

task :default => ["serve:development"]

desc "cleans the output directory"
task :clean do
  sh "jekyll clean"
end

namespace :deploy do

  desc "upload to S3"
  task :s3upload => [] do
    bucket = `aws s3api list-buckets --query "Buckets[?contains(Name, '#{hostname}')] | [0].Name" | jq -r '.'`

    p "Uploading to #{bucket} in #{region}"

    htmls = File.join("**", "*.html")

    # Remove extension from HTML files
    Dir.glob(htmls, base: "_site") do |filename|
      # Skip index.html
      next if filename == "index.html"

      filename_noext = filename.sub('.html', '')
      p "Will move #{filename} to #{filename_noext}"
      FileUtils.mv(filename, filename_noext)
    end

    p "Will upload non-HTML files"
    sh %{
      aws s3 sync _site/ s3://#{bucket} --region #{region} --delete \
      --size-only --exclude "*" --include "*.*"
    }

    p "Will upload HTML files"
    sh %{
      aws s3 sync _site/ s3://#{bucket} --region #{region} --delete \
      --content-type "text/html; charset=utf-8" --exclude "*.*"
    }
  end
end

namespace :build do

  desc "build development site"
  task :development => [:clean] do
    sh "jekyll build --drafts"
  end

  desc "build production site"
  task :production => [:clean] do
    sh "JEKYLL_ENV=production jekyll build --config=_config.yml"
  end
end

namespace :serve do

  desc "serve development site"
  task :development => [:clean] do
    sh "jekyll serve --drafts"
  end

  desc "serve production site"
  task :production => [:clean] do
    sh "JEKYLL_ENV=production jekyll serve --config=_config.yml"
  end
end

namespace :test do

  desc "test production build"
  task :production => ["build:production"] do
    HTMLProofer.check_directory($outputDir, $testOpts).run
  end
end
