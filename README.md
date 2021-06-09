# CharityCrowd

Create databases:
  * `createdb charity_crowd_dev`
  * `createdb charity_crowd_test`
  * In postgres: `CREATE USER charity_crowd WITH PASSWORD 'charity_crowd';`
  * `GRANT ALL ON DATABASE charity_crowd_dev TO charity_crowd;`
  * `GRANT ALL ON DATABASE charity_crowd_test TO charity_crowd;`

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
