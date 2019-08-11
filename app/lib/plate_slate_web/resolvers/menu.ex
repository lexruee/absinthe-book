defmodule PlateSlateWeb.Resolvers.Menu do
  alias PlateSlate.Menu

  def menu_items(_, args, _) do
    {:ok, Menu.list_items(args)}
  end

  def menu_item(_, args, _) do
    {:ok, Menu.get_item!(args)}
  end
end