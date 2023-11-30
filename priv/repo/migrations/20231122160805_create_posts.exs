defmodule XDemo.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :body, :string
      add :likes_count, :integer
      add :repost_count, :integer
      add :photo_locations, {:array, :string}, null: false, default: []
      add :user_id, references(:users, on_delete: :nothing)
      timestamps()
    end
  end
end
