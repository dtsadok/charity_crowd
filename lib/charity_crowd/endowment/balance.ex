defmodule CharityCrowd.Endowment.Balance do
  use Ecto.Schema
  import Ecto.Changeset

  schema "balances" do
    field :amount_cents, :integer
    field :date, :date

    timestamps()
  end

  @doc false
  def changeset(balance, attrs) do
    balance
    |> cast(attrs, [:amount_cents, :date])
    |> validate_required([:amount_cents, :date])
  end
end
