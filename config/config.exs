use Mix.Config

if Mix.env in ~w(docs)a do
  config :ex_doc, :markdown_processor, ExDoc.Markdown.Cmark
end
