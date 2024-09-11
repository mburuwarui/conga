defmodule Conga.Posts.ReactionType do
  @reaction_types [:like, :love, :haha, :wow, :sad, :angry]

  def all, do: @reaction_types

  def valid?(type) when is_atom(type), do: type in @reaction_types
  def valid?(type) when is_binary(type), do: String.to_existing_atom(type) in @reaction_types
  def valid?(_), do: false

  def to_atom(type) when is_binary(type), do: String.to_existing_atom(type)
  def to_atom(type) when is_atom(type), do: type

  def to_string(type) when is_atom(type), do: Atom.to_string(type)
  def to_string(type) when is_binary(type), do: type
end
