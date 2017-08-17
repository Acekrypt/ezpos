== EZPOS

This is a fairly old (mid 2000s) Point Of Sale (POS) application I wrote for internal use at a distribution company.  It would be installed on laptops and taken to trade shows for selling miscellaneous items.

I seem to recall we would give the users USB sticks with DB updates and Linux would use automount scripts to auto-install them when inserted, and then dump a sales report back in the stick.

It's written in Ruby using the GTK bindings.  Not really sure why it's a old Rails 2.1 app, other than I probably couldn't figure out how to use ActiveRecord by itself without the entire Rails framework.  I seem to recall that things were fairly tightly coupled back then.

The interesting bits seem to be in [lib/nas](/tree/master/lib/nas) and [app/models](/tree/master/app)

![Alt text](/screenshot.png?raw=true "EZPOS Screenshot")
