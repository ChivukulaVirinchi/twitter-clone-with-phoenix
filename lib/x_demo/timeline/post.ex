defmodule XDemo.Timeline.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :body, :string
    field :likes_count, :integer, default: 0
    field :repost_count, :integer, default: 0
    field :photo_locations, {:array, :string}, default: []
    belongs_to :user, XDemo.Accounts.User
    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:body, :photo_locations])
    |> validate_required([:body])
  end
end
