SRCS = src/*.elm src/*/*.elm
TESTS = tests/*.elm
DEST = public/app.js

$(DEST): $(SRCS)
	elm make src/App.elm --output $(DEST)

format:
	elm-format --yes $(SRCS) $(TESTS)

validate:
	elm-format --validate $(SRCS) $(TESTS)

lint:
	elm-analyse

test:
	elm-test
