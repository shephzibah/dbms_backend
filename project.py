from flask import Flask, request, jsonify
import pymysql.cursors
from flask_cors import CORS  # Import the CORS extension
import pymysql.cursors
from datetime import datetime 
from flask_bcrypt import generate_password_hash
from flask_bcrypt import Bcrypt

app = Flask(__name__)
CORS(app)
bcrypt = Bcrypt(app)

# Database connection configuration
db_config = {
    'host': 'localhost',
    'user': 'root',
    'password': '12345678',
    'database': 'airport',
    'port':3306 ,
    'cursorclass': pymysql.cursors.DictCursor
}

@app.route('/')
def index():
    return jsonify({'message': 'Welcome to the API'})

# Function to execute a MySQL query
def execute_query(query, params=None):
    connection = pymysql.connect(**db_config)
    try:
        with connection.cursor() as cursor:
            cursor.execute(query, params)
            result = cursor.fetchall()
    finally:
        connection.commit()
        connection.close()
    return result

# API endpoint for user registration
@app.route('/api/register', methods=['POST'])
def register():
    data = request.get_json()
    name = data.get('name')
    email = data.get('email')
    password = data.get('password')
    date_of_birth = data.get('dateOfBirth')
    city = data.get('city')

    query = "CALL createNewUser(%s, %s, %s, %s, %s);"
    params = (name, email, password, date_of_birth, city)

    print("name, email, password, date_of_birth, city", name, email, password, date_of_birth, city)

    try:
        execute_query(query, params)
        return jsonify({'success': True, 'message': 'User registered successfully'})
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)})

@app.route('/api/login', methods=['POST'])
def passenger_login():
    try:
        data = request.get_json()

        # Check if data is None
        if data is None:
            return jsonify({'success': False, 'message': 'Invalid JSON data', 'is_staff': False})

        # Extract data from the request
        email = data.get('email')
        password = data.get('password')
        # email='renusreechava@gmail.com'
        # password='pass1'

        # Check if the email belongs to a staff member
        query_staff = "SELECT * FROM ground_staff WHERE employee_email = %s AND employee_password = %s"
        params_staff = (email, password)

        connection_staff = pymysql.connect(**db_config)
        try:
            with connection_staff.cursor() as cursor_staff:
                cursor_staff.execute(query_staff, params_staff)
                result_staff = cursor_staff.fetchone()
        finally:
            connection_staff.close()

        if result_staff:
            # Staff member login
            return jsonify({'success': True, 'message': 'Staff login successful', 'is_staff': True})
        else:
            # Check if the email belongs to a regular user
            query_passenger = "SELECT * FROM passengers WHERE email = %s AND passoword = %s"
            params_passenger = (email, password)

            connection_passenger = pymysql.connect(**db_config)
            try:
                with connection_passenger.cursor() as cursor_passenger:
                    cursor_passenger.execute(query_passenger, params_passenger)
                    result_passenger = cursor_passenger.fetchone()
            finally:
                connection_passenger.close()

            if result_passenger:
                # Regular user login
                return jsonify({'success': True, 'message': 'Passenger login successful', 'is_staff': False})
            else:
                # Invalid email or password
                return jsonify({'success': False, 'message': 'Invalid email or password', 'is_staff': False})
    except Exception as e:
        return jsonify({'success': False, 'message': str(e), 'is_staff': False})


# ... (your existing imports and code)

@app.route('/api/flights', methods=['POST'])
def get_available_flights():
    try:
        data = request.get_json()

        source_city = data.get('src')
        destination_city = data.get('dst')
        date = data.get('date')

        # Print the received date for debugging
        print("Received date:", date)

        query = """
        SELECT 
            s.schedule_id,
            CONCAT(YEAR(s.dept_time), '-', LPAD(MONTH(s.dept_time), 2, '0'), '-', LPAD(DAY(s.dept_time), 2, '0'), ' ', LPAD(HOUR(s.dept_time), 2, '0'), ':', LPAD(MINUTE(s.dept_time), 2, '0'), ':', LPAD(SECOND(s.dept_time), 2, '0')) AS Time_of_Departure,
            CONCAT(YEAR(s.arr_time), '-', LPAD(MONTH(s.arr_time), 2, '0'), '-', LPAD(DAY(s.arr_time), 2, '0'), ' ', LPAD(HOUR(s.arr_time), 2, '0'), ':', LPAD(MINUTE(s.arr_time), 2, '0'), ':', LPAD(SECOND(s.arr_time), 2, '0')) AS Time_of_Arrival,
            s.route_id,
            r.origin,
            r.destination,
            s.fare,
            s.tickets_left
        FROM 
            schedules s
            JOIN routes r ON s.route_id = r.route_id
        WHERE 
            r.origin = %s
            AND r.destination = %s
            AND DATE(s.dept_time) = %s;
        """

        params = (source_city, destination_city, date)

        try:
            flights = execute_query(query, params)
            return jsonify({'success': True, 'flights': flights})
        except Exception as e:
            return jsonify({'success': False, 'message': str(e)})
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)})


# API endpoint to book a specific flight
@app.route('/api/book-flight', methods=['POST'])
def book_flight():
    schedule_id = request.json.get('schedule_id')
    user_email = request.json.get('user_email')

    # Check if the schedule exists and has available seats
    check_query = "SELECT * FROM schedules WHERE schedule_id = %s AND tickets_left > 0"
    check_params = (schedule_id,)

    try:
        result = execute_query(check_query, check_params)
        if not result:
            return jsonify({'success': False, 'message': 'Invalid schedule ID or no available seats'})
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)})

    # Book the flight
    book_query = "INSERT INTO booking (schedule_id, passenger_id) VALUES (%s, (SELECT passenger_id FROM passengers WHERE email = %s))"
    book_params = (schedule_id, user_email)

    try:
        execute_query(book_query, book_params)

        # Get the booking ID for the response
        booking_id_query = "SELECT * FROM booking ORDER BY booking_id DESC LIMIT 1;"
        booking_id_result = execute_query(booking_id_query)

        return jsonify({'success': True, 'message': 'Booking successful', 'booking_id': booking_id_result[0]['booking_id']})
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)})

# API endpoint to cancel a flight booking
@app.route('/api/cancel-booking', methods=['POST'])
def cancel_booking():
    user_name = request.json.get('user_name')
    booking_id = request.json.get('booking_id')
    print("Received booking_id:", booking_id)
    # Check if the booking exists
    check_query = """
        SELECT b.*, s.tickets_left
        FROM booking b
        JOIN schedules s ON b.schedule_id = s.schedule_id
        WHERE b.booking_id = %s
    """
    check_params = (booking_id,)

    try:
        result = execute_query(check_query, check_params)
        if not result:
            return jsonify({'success': False, 'message': 'Invalid booking ID'})
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)})

    # Cancel the booking and update available seats
    cancel_query = """
        DELETE FROM booking
        WHERE booking_id = %s AND passenger_id = (SELECT passenger_id FROM passengers WHERE passenger_name = %s)
    """
    cancel_params = (booking_id, user_name)

    try:
        execute_query(cancel_query, cancel_params)
        return jsonify({'success': True, 'message': 'Booking canceled successfully'})
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)})

# API endpoint to display all available schedules
@app.route('/api/available-schedules', methods=['GET'])
def get_available_schedules():
    try:
        # Query to retrieve all available schedules
        query = """
        SELECT 
            s.schedule_id,
            CONCAT(YEAR(s.dept_time), '-', LPAD(MONTH(s.dept_time), 2, '0'), '-', LPAD(DAY(s.dept_time), 2, '0'), ' ', LPAD(HOUR(s.dept_time), 2, '0'), ':', LPAD(MINUTE(s.dept_time), 2, '0'), ':', LPAD(SECOND(s.dept_time), 2, '0')) AS Time_of_Departure,
            CONCAT(YEAR(s.arr_time), '-', LPAD(MONTH(s.arr_time), 2, '0'), '-', LPAD(DAY(s.arr_time), 2, '0'), ' ', LPAD(HOUR(s.arr_time), 2, '0'), ':', LPAD(MINUTE(s.arr_time), 2, '0'), ':', LPAD(SECOND(s.arr_time), 2, '0')) AS Time_of_Arrival,
            s.route_id,
            r.origin,
            r.destination,
            s.fare,
            s.tickets_left
        FROM 
            schedules s
            JOIN routes r ON s.route_id = r.route_id
        WHERE 
            s.tickets_left > 0;  -- Include only available schedules
        """

        try:
            available_schedules = execute_query(query)
            return jsonify({'success': True, 'available_schedules': available_schedules})
        except Exception as e:
            return jsonify({'success': False, 'message': str(e)})
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)})


# API endpoint to change a schedule
@app.route('/api/change-schedule/<int:schedule_id>', methods=['PUT'])
def change_schedule(schedule_id):
    try:
        # Get updated schedule data from request
        updated_data = request.get_json()

        # Check if the schedule exists
        check_query = "SELECT * FROM schedules WHERE schedule_id = %s"
        check_params = (schedule_id,)
        existing_schedule = execute_query(check_query, check_params)

        if not existing_schedule:
            return jsonify({'success': False, 'message': 'Schedule not found'})

        # Update the schedule in the database without changing route_id
        update_query = """
            UPDATE schedules
            SET dept_time = %s, arr_time = %s, fare = %s, tickets_left = %s
            WHERE schedule_id = %s
        """
        update_params = (
            updated_data['dept_time'],
            updated_data['arr_time'],
            updated_data['fare'],
            updated_data['tickets_left'],
            schedule_id,
        )

        execute_query(update_query, update_params)

        return jsonify({'success': True, 'message': 'Schedule updated successfully'})
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)})



# API endpoint to add a new schedule
@app.route('/api/add-schedule', methods=['POST'])
def add_schedule():
    try:
        # Get schedule data from request
        schedule_data = request.get_json()

        # Insert the new schedule into the database
        insert_query = """
            INSERT INTO schedules (dept_time, arr_time, route_id, fare, tickets_left,aircraft_id)
            VALUES (%s, %s, %s, %s, %s,%s)
        """
        insert_params = (
            schedule_data['dept_time'],
            schedule_data['arr_time'],
            schedule_data['route_id'],
            schedule_data['fare'],
            schedule_data['tickets_left'],
            schedule_data['aircraft_id']
        )

        execute_query(insert_query, insert_params)

        return jsonify({'success': True, 'message': 'Schedule added successfully'})
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)})

# API endpoint to delete a schedule
@app.route('/api/delete-schedule', methods=['POST'])
def delete_schedule():
    try:
        # Get schedule ID from request
        schedule_id = request.json.get('schedule_id')

        # Check if the schedule exists
        check_query = "SELECT * FROM schedules WHERE schedule_id = %s"
        check_params = (schedule_id,)
        existing_schedule = execute_query(check_query, check_params)

        if not existing_schedule:
            return jsonify({'success': False, 'message': 'Schedule not found'})

        # Delete the schedule from the database
        delete_query = "DELETE FROM schedules WHERE schedule_id = %s"
        delete_params = (schedule_id,)
        execute_query(delete_query, delete_params)

        return jsonify({'success': True, 'message': 'Schedule deleted successfully'})
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)})

# API endpoint to get all passengers for a given flight
@app.route('/api/passengers-for-flight', methods=['GET'])
def get_passengers_for_flight():
    schedule_id = request.args.get('schedule_id')

    # Check if the schedule exists
    check_query = """
        SELECT *
        FROM schedules
        WHERE schedule_id = %s
    """
    check_params = (schedule_id,)

    try:
        result = execute_query(check_query, check_params)
        if not result:
            return jsonify({'success': False, 'message': 'Invalid schedule ID'})
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)})

    # Retrieve passengers for the given flight
    passengers_query = """
        SELECT p.passenger_id, p.passenger_name, p.email
        FROM passengers p
        JOIN booking b ON p.passenger_id = b.passenger_id
        WHERE b.schedule_id = %s
    """
    passengers_params = (schedule_id,)

    try:
        passengers = execute_query(passengers_query, passengers_params)
        return jsonify({'success': True, 'passengers': passengers})
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)})

# API endpoint to update passenger details for a specific flight
@app.route('/api/update-passenger-details', methods=['POST'])
def update_passenger_details():
    try:
        data = request.get_json()

        # Extract data from the request
        passenger_id = data.get('passenger_id')
        new_name = data.get('new_name')
        new_email = data.get('new_email')

        # Check if the passenger exists
        check_passenger_query = """
            SELECT *
            FROM passengers
            WHERE passenger_id = %s
        """
        check_passenger_params = (passenger_id,)

        connection = pymysql.connect(**db_config)
        try:
            with connection.cursor() as cursor:
                cursor.execute(check_passenger_query, check_passenger_params)
                result = cursor.fetchone()
                if not result:
                    return jsonify({'success': False, 'message': 'Passenger not found'})
        finally:
            connection.close()

        # Update passenger details
        update_passenger_query = """
            UPDATE passengers
            SET passenger_name = %s, email = %s
            WHERE passenger_id = %s
        """
        update_passenger_params = (new_name, new_email, passenger_id)

        execute_query(update_passenger_query, update_passenger_params)

        return jsonify({'success': True, 'message': 'Passenger details updated successfully'})
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)})



if __name__ == '__main__':
    app.run(debug=True)
