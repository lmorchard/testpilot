#!/bin/bash

# TODO XXX We should re-enable our integration tests!
#  * flaky tests are worse than no tests
#  * Jared is going to look at having the integration tests hit t.f.c/files/
#    directly which would still test the install, but would bypass all of the
#    hard-to-hit prompts (hopefully fixing the flakiness?)
#  * disabling these now lets us land greenkeeper and update a lot of out of
#    date libraries (~25)
#  * r=_6a68 and r=clouserw.  Conveniently discussed over the holiday break ;)

cd sc-*-linux && ./bin/sc --user $SAUCE_USERNAME --api-key $SAUCE_ACCESS_KEY --readyfile ~/sauce_is_ready:
  background: true
# Wait for tunnel to be ready

npm start &
STATIC_SERVER_PID=$!

while [ ! -e ~/sauce_is_ready ]; do sleep 1; done
# Wait for app to be ready
wget --retry-connrefused --no-check-certificate -T 30 https://example.com:8000

# Fire up the integration tests with Marionette
tox
TEST_STATUS=$?

kill $STATIC_SERVER_PID

# Report what happened
if [ $TEST_STATUS -eq 0 ]
then
  echo "Integration tests passed."
  exit 0
else
  echo "Integration tests failed!"
  exit 1
fi
