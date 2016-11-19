# Serialcaster: personal podcasts from S3

This is a simple app that will generate podcasts from a collection of audio files in an S3 bucket and release them on a schedule you set. I built it so I can listen to some old radio drama serials I have as CDs in my podcatching app, and have 'new' episodes come out a couple of times a week.

It's designed to be run as a Heroku app, and should run just fine on a hobby dyno.

## Setup

Your heroku app needs to have the following config variables set:

`SERIALCASTER_SEKRIT_TOKEN` should be set to some random string and is the auth token used for making sure that only you, or people you give a link to, can actually access your podcast.

`SERIALCASTER_BUCKET` should be set to the name of your S3 bucket which contains your podcast files.

`AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` should be set to the AWS credentials for a user that has read access to your bucket.

`AWS_REGION` should be set to the AWS region that your bucket is in.

## Config

Config is all done by putting files into S3. Each podcast should live in its own folder in the S3 bucket. You need to put a JSON file named `programme.json` in the folder, along with all your `.mp3` or `.m4a` files.

The `programme.json` file looks like this:

```json
{
  "programme": "Journey Into Space",
  "description": "Classic BBC radio drama",
  "episode_file_patterns": [
    "(?<title>Journey Into Space - Operation Luna) - Episode (?<episode>[0-9]+)",
    "Journey Into Space - (?<title>The Red Planet) - Episode (?<episode>[0-9]+)"
  ],
  "schedule": {
    "starting_from": "2016-11-18",
    "days": [
      "sunday",
      "wednesday"
    ],
    "time": "17:00"
  }
}
```

The `programme` value is the name of the Podcast. `description` will be used as the description.

`episode_file_patterns` is an Array of strings that will be compiled into Regexes to extract information from the audio file names to help generating episode titles and sorting the episodes into the correct order. This uses Regex named captures. You can use `title` and `episode` to extract episode title and which episode number it is. This is optional: you can just use a simple regex to pick the right filename (like `.*mp3`) and the files will be sorted alphabetically. Each entry in the array is treated like a season, so everything matched by the first entry will be scheduled before anything matched by the second.

in the `schedule` block, `starting_from` is the earliest date episodes should appear. `days` controls on which days of the week new episodes will be published, and `time` controls what time of day new episodes will be published at.

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/fidothe/serialcaster. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

This app is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).


