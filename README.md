# PrettySql

This gem is not yet released and is currently a work in progress. Not intended for production use.

Example output:

```
User.joins(:account_users).where.not(first_name: nil).where(first_name: ["Foo", "Bar", "Baz"]).where(onboarded: [false, nil]).limit(20).first

User Load (20.6ms)

SELECT "users".*
FROM "users"
INNER JOIN "account_users" ON "account_users"."user_id" = "users"."id"
WHERE "users"."deleted_at" IS NULL
  AND "users"."first_name" IS NOT NULL
  AND "users"."first_name" IN ('Foo', 'Bar', 'Baz')
  AND ("users"."onboarded" = false OR "users"."onboarded" IS NULL)
ORDER BY "users"."created_at" ASC, "users"."id" ASC
LIMIT 1
Limit  (cost=69.48..69.48 rows=1 width=917) (actual time=0.542..0.543 rows=0 loops=1)
  ->  Sort  (cost=69.48..69.48 rows=1 width=917) (actual time=0.541..0.542 rows=0 loops=1)
        Sort Key: users.created_at, users.id
        Sort Method: quicksort  Memory: 25kB
        ->  Nested Loop  (cost=0.28..69.47 rows=1 width=917) (actual time=0.538..0.539 rows=0 loops=1)
              ->  Seq Scan on users  (cost=0.00..68.06 rows=1 width=917) (actual time=0.538..0.538 rows=0 loops=1)
                    Filter: ((deleted_at IS NULL) AND (first_name IS NOT NULL) AND ((NOT onboarded) OR (onboarded IS NULL)) AND ((first_name)::text = ANY ('{Foo,Bar,Baz}'::text[])))
                    Rows Removed by Filter: 1155
              ->  Index Only Scan using index_account_users_on_user_id on account_users  (cost=0.28..1.40 rows=1 width=16) (never executed)
                    Index Cond: (user_id = users.id)
                    Heap Fetches: 0
Planning Time: 0.571 ms
Execution Time: 0.598 ms
```

## Installation

TODO: Replace `UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG` with your gem name right after releasing it to RubyGems.org. Please do not do it earlier due to security reasons. Alternatively, replace this section with instructions to install your gem from git if you don't plan to release to RubyGems.org.

Install the gem and add to the application's Gemfile by executing:

    $ bundle add UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG

## Usage

Simply configure within your environment file, e.g.,

```ruby
# development.rb
config.after_initialize do
  PrettySql.enable!
  PrettySql.sql_output_colour = :cyan
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/pretty_sql. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/pretty_sql/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the PrettySql project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/pretty_sql/blob/main/CODE_OF_CONDUCT.md).
