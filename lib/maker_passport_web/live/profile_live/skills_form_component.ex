defmodule MakerPassportWeb.ProfileLive.SkillsFormComponent do
  use MakerPassportWeb, :live_component

  alias MakerPassport.Maker.Skill

  @impl true
  def render(assigns) do
    ~H"""
    <div>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok, socket
    |> assign(assigns)
    |> assign_new(:skills_form, fn ->
      to_form(Skill.changeset(%Skill{}))
    end)}
  end

end
