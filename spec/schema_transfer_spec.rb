  #these specs whilst as generic as possilbe dependent on a specific
  #config/database.yml not in git
  #
  #Currently targetting loading a schema from a sybase install over which we
  #have no control and loading into a postgres db for testing which we can
  #control and create records/specs/factories etc.
  #
  #They expect something like:
  #
  #production:
  #  adapter: sybase
  #  credentials: go
  #  in: here
  #
  #test_db:
  #  adapter: pg
  #  credentials: go
  #  in: here
  #

