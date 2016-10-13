if [ -z "$GERRIT_FETCH_URL" ] ; then export GERRIT_FETCH_URL=git://review.mycompany.net ; fi
if [ -z "$GERRIT_PUSH_URL" ] ;  then export GERRIT_PUSH_URL=$GERRIT_FETCH_URL ; fi
