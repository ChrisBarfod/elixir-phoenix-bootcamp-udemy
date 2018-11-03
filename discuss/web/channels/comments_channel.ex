defmodule Discuss.CommentsChannel do
  use Discuss.Web, :channel

  alias Discuss.{Topic, Comment} # This syntax condenses 2 alias statements into one

  def join("comments:" <> topic_id, _params, socket) do # <> is how to join strings in Elixir
    topic_id = String.to_integer(topic_id) 
    topic = Topic
      |> Repo.get(topic_id) # look into Repo and pull out the topic with its equivalent id
      |> Repo.preload(comments: [:user]) # load records(comments) that are associated with topic

    {:ok, %{comments: topic.comments}, assign(socket, :topic, topic)}
  end

  def handle_in(name, %{"content" => content}, socket) do
    topic = socket.assigns.topic
    user_id = socket.assigns.user_id

    changeset = topic
    |> build_assoc(:comments, user_id: user_id)
    |> Comment.changeset(%{content: content})

    case Repo.insert(changeset) do
      {:ok, comment} ->
        broadcast!(socket, "comments:#{socket.assigns.topic.id}:new", 
          %{comment: comment}
        )
        {:reply, :ok, socket}
      {:error, _reason} -> 
        {:reply, {:error, %{errors: changeset}}, socket}
    end
  end
end
