SRCS = src/*.elm src/*/*.elm
TESTS = tests/*.elm
DEST = public/bundle.js

$(DEST): $(SRCS)
	elm make src/Main.elm --output $(DEST)

start: $(DEST)
	node server.js

clean:
	rm -rf $(DEST) elm-stuff

format:
	elm-format --yes $(SRCS) $(TESTS)

validate:
	elm-format --validate $(SRCS) $(TESTS)

lint:
	elm-analyse | grep -v '^INFO: '

test:
	script -q /dev/null elm-test
