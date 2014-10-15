test "GET /events initially",
   requires => [qw( do_request_json_authed )],

   check => sub {
      my ( $do_request_json_authed ) = @_;

      $do_request_json_authed->(
         method => "GET",
         uri    => "/events",
         params => { timeout => 0 },
      )->then( sub {
         my ( $body ) = @_;

         json_keys_ok( $body, qw( start end chunk ));
         ref $body->{chunk} eq "ARRAY" or die "Expected 'chunk' as a JSON list\n";

         # We can't be absolutely sure that there won't be any events yet, so
         # don't check that.

         provide GET_current_event_token => sub {
            $do_request_json_authed->(
               method => "GET",
               uri    => "/events",
               params => { from => "END", timeout => 0 },
            )->then( sub {
               my ( $body ) = @_;
               Future->done( $body->{end} );
            });
         };

         Future->done(1);
      });
   };
