
-record (user, {
	id = null,
	user_name = null,
	user_password = null,
	user_class = null,
	user_email = []}).

-record (airport, {
	id = null,
	iata = null,
	airport_name = null}).

-record (flights, {
	id = null,
	airport = null,
	arrival_point = null,
	departuer_date = null,
	arrival_date = null,
	flight_id = null,
	price = null}).

-record (seats, {
	id = null,
	flights = null,
	class = null,
	user = null,
	window = null,
	ailside = null,
	row = null,
	col = null,
	lock_s = null}).
