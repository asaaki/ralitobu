all: docs lint

docs:
	@MIX_ENV=docs mix docs

lint:
	mix credo --strict

build:
	@mix compile --force

### PUBLISH

publish: publish-code publish-docs

publish-code: build
	@mix hex.publish

publish-docs: docs
	@MIX_ENV=docs mix hex.docs
