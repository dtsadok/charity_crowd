# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     CharityCrowd.Repo.insert!(%CharityCrowd.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

CharityCrowd.Repo.insert!(%CharityCrowd.Endowment.Balance{amount_cents: 1000_00})
