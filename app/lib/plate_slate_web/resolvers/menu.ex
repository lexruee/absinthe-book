defmodule PlateSlateWeb.Resolvers.Menu do
  alias PlateSlate.Menu

  def create_menu_item(_, %{input: params}, _) do
    case Menu.create_item(params) do
      {:error, changeset} ->
        {:ok, %{errors: transform_errors(changeset)}}
      {:ok, menu_item} ->
        {:ok, %{menu_item: menu_item}}
    end
  end
  defp transform_errors(changeset) do
    changeset
    |> Ecto.Changeset.traverse_errors(&format_error/1)
    |> Enum.map(fn
      {key, value} ->
        %{key: key, message: value}
    end)
  end
  @spec format_error(Ecto.Changeset.error) :: String.t
  defp format_error({msg, opts}) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", to_string(value))
    end)
  end

  def update_menu_item(_, %{id: id, input: params}, _) do
    menu_item = Menu.get_item!(%{id: id})
    case Menu.update_item(menu_item, params) do
      {:error, changeset} ->
        {:ok, %{errors: transform_errors(changeset)}}
      {:ok, menu_item} ->
        {:ok, %{menu_item: menu_item}}
    end
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