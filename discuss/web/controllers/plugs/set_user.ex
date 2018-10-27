defmodule Discuss.Plugs.SetUser do

# The sole purpose of this plug is to look at our connection object to see if
# there is a user ID assigned to it. If there is, that user will be found in
# the database and assigned to the connection object so any follow up request 
# will have access to the user object. - helpful to see if a user is associated
# with a post or checking to see if a user has permission to delete a post.

  import Plug.Conn #gives access to assign
  import Phoenix.Controller #gives us access to 'get_session'

  alias Discuss.Repo
  alias Discuss.User

  # if you ever have an expensive operation to do:
  # eg. pull a bunch of data out of the database and then do some 
  # expensive computation on it.
  # This would be a great thing to do inside your init function because
  # its only going to run this one time. Every follow up time it'll
  # be automatically injectiod in as a second argument to your 
  # call function.
  def init(_params) do 
  end

  def call(conn, _params) do # the params argument here is whatever is returned from the init function
    user_id = get_session(conn, :user_id)

    # condition statement - executes whichever expression which evaluates to true first.
    # A user struct is coming out of the database that will be assigned to the user variable.
    cond do
      # We are using this to assign our user to the user variable
      # We are using this overall to get a truth value for the conditon statement.
      user = user_id && Repo.get(User, user_id) ->
        # Modify assigns property on our connection object
        # use function called 'assign', pass in connection object, then pass in
        # property we want to modify 'user'. Because we fetched a user - 
        # we assign this to the :user property.
        assign(conn, :user, user)
        # now we can make reference to conn.assigns.user => (this will make reference to our) user struct

      # cond statements - true - are always going to be executed if they're last
      true ->
        assign(conn, :user, nil)
    end
  end
end
