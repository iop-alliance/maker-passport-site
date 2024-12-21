defmodule MakerPassport.Permissions do
  @moduledoc """
  Provides permission checks for different user roles.
  """
  use Permit.Permissions, actions_module: Permit.Phoenix.Actions

  def can(%{role: "admin"}) do
    permit()
    |> all(MakerPassport.Visitors.Visitor)
    |> all(MakerPassport.Profile)
  end

  def can(_), do: permit()
end

defmodule MakerPassport.Authorization do
  @moduledoc """
  Handles authorization logic using defined permissions.
  """
  use Permit, permissions_module: MakerPassport.Permissions
end
