SRCS = src/*.elm src/*/*.elm
DEST = public/app.js

$(DEST): $(SRCS)
	elm make src/App.elm --output $(DEST)

format:
	elm-format --yes $(SRCS)

validate:
	elm-format --validate $(SRCS)
