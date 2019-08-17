defmodule PlateSlateWeb.Resolvers.Menu do
  alias PlateSlate.Menu

  def create_menu_item(_, %{input: params}, _) do
    case Menu.create_item(params) do
      {:error, changeset} ->
        {:error, message: "Could not create menu item", details: error_details(changeset)}
      {:ok, _} = success ->
        success
    end
  end
  defp error_details(changeset) do
    changeset
    |> Ecto.Changeset.traverse_errors(fn {msg, _} -> msg end)
  end

  def menu_items(_, args, _) do
    {:ok, Menu.list_items(args)}
  end

  def menu_item(_, args, _) do
    {:ok, Menu.get_item!(args)}
  end

  def items_for_category(category, _args, _) do
    query = Ecto.assoc(category, :items)
    {:ok, PlateSlate.Repo.all(query)}
  end

  def search(_, %{matching: term}, _) do
    {:ok, Menu.search(term)}
  end
end