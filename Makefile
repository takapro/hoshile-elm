SRCS = src/*.elm
DEST = public/app.js

$(DEST): $(SRCS)
	elm make $(SRCS) --output $(DEST)

format:
	elm-format --yes $(SRCS)

validate:
	elm-format --validate $(SRCS)
