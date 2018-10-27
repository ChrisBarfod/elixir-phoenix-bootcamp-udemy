defmodule Discuss.AuthController do
  use Discuss.Web, :controller
  plug Ueberauth

  alias Discuss.User

  # The assigns property is used for assigning data that we want to carry along
  # inside our connection - as developers we can stash data that will be used
  # in other parts of our application.
  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    # user_params is a map of all the properties that we want to insert into the database
    user_params = %{token: auth.credentials.token, email: auth.info.email, provider: "github"}
    changeset = User.changeset(%User{}, user_params) 

    signin(conn,changeset)
  end

  def signout(conn, _params) do
    conn
    |> configure_session(drop: true) #drops entire session so there's no trace of user on their session. - future proof in the case that we store any other sensitive data in the session, this won't bleed into any subsiquent requests.
    |> redirect(to: topic_path(conn, :index))
  end

  defp signin(conn, changeset) do
    case insert_or_update_user(changeset) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Welcome back!")
        |> put_session(:user_id, user.id)
        |> redirect(to: topic_path(conn, :index)) # Redirects back to index
      {:error, _reason} ->
        conn
        |> put_flash(:error, "Error signing in")
        |> redirect(to: topic_path(conn, :index))
    end
  end
  
  # defp stands for a private function that is only accessible within this model
  defp insert_or_update_user(changeset) do
    case Repo.get_by(User, email: changeset.changes.email) do
      nil ->
        Repo.insert(changeset)
      user ->
        {:ok, user}
    end
  end
end
