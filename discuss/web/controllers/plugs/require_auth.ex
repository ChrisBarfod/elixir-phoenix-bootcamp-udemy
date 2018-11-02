defmodule Discuss.Plugs.RequireAuth do
  import Plug.Conn
  import Phoenix.Controller

  alias Discuss.Router.Helpers

  # init and call are the two function required inside every plug.

  # init is used for any long running or expensive operations - only executed one time.
  def init(_params) do
  end

  # _params object is whatever was called from the init function.
  def call(conn, _params) do
    if conn.assigns[:user] do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in")
      |> redirect(to: Helpers.topic_path(conn, :index))
      |> halt()
    end
  end

end
