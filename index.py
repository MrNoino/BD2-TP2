from flask import Flask, jsonify, request
import db_wrapper, jwt 
from functools import wraps
from datetime import datetime, timedelta
import os, env

OK = 200

NOT_FOUND = 404

BAD_REQUEST = 400

UNAUTHORIZED = 401

FORBIDDEN = 403

INTERNAL_SERVER_ERROR = 500

METHOD_NOT_ALLOWED = 405

app = Flask(__name__)

# !!! AUTH !!!
def auth_user(func):

    @wraps(func)
    def verify_token(*args, **kwargs):

        if "Authorization" in request.headers:

            token = request.headers["Authorization"].split(" ")[1]

        else:

            return jsonify({'Erro': 'Token está em falta!'}), BAD_REQUEST

        if not token:

            return jsonify({'Erro': 'Token está em falta!'}), BAD_REQUEST

        try:

            decoded_token = jwt.decode(token, os.environ["SECRET_KEY"], algorithms=["HS256"])

            if(decoded_token["expiration"] < str(datetime.utcnow())):

                return jsonify({"Erro": "O Token expirou!"}), FORBIDDEN

        except Exception as e:

            return jsonify({'Erro': str(e)}), UNAUTHORIZED
        
        return func(*args, **kwargs)
    
    return verify_token


# !!! START !!!
@app.route("/")
def hello_world():

    return jsonify({"message": "Welcome To IOT API"}), OK

# !!! LOGIN !!!
@app.post("/login/")
def login():

    parameters = request.get_json()

    received_parameters = ['email', 'password']

    if not all(parameter in parameters for parameter in received_parameters):

        return jsonify({'message': 'Parâmetros em falta'}), BAD_REQUEST

    query = '''SELECT * FROM login(%(email)s, %(password)s);'''

    data = db_wrapper.generic_select(query, parameters)

    if data:

        token = jwt.encode({
                    'id': data[0]["id"],
                    'expiration': str(datetime.utcnow() + timedelta(weeks=5))
                }, os.environ["SECRET_KEY"])

        return jsonify({'token': token}), OK
    
    else:

        return jsonify({'message': 'Erro no login.'}), INTERNAL_SERVER_ERROR


# !!! SYSTEM !!!
@app.route("/system/<id>", methods=['GET', 'DELETE'])
@app.route("/system/", methods=['GET', 'POST', 'PUT'])
@auth_user
def system(id = None):

    if request.method == 'GET':

        if id:

            query = 'SELECT * FROM system_view(%(id)s);'
            parameters = {"id": id}
            data = db_wrapper.generic_select(query, parameters)

            if data:

                data = data[0]

        else:

            query = 'SELECT * FROM system_view;'
            data = db_wrapper.generic_select(query)

        if not data:

            return jsonify({'message': 'Nenhum sistema encontrado.'}), NOT_FOUND

        return jsonify(data), OK

    elif request.method == 'POST':

        parameters = request.get_json()

        received_parameters = ['location', 'property', 'owner_id']

        if not all(parameter in parameters for parameter in received_parameters):

            return jsonify({'message': 'Parâmetros em falta'}), BAD_REQUEST

        query = '''CALL system_insert(%(location)s, %(property)s, %(owner_id)s);'''

        inserted = db_wrapper.generic_manipulation(query, parameters)

        if inserted:

            return jsonify({'message': 'Inserido com sucesso'}), OK
        
        else:

            return jsonify({'message': 'Erro no servidor.'}), INTERNAL_SERVER_ERROR

    elif request.method == 'PUT':

        parameters = request.get_json()

        received_parameters = ['id']

        if not all(parameter in parameters for parameter in received_parameters):

            return jsonify({'message': 'Parâmetros em falta'}), BAD_REQUEST

        query = '''CALL system_update('''

        for parameter in parameters:

            query += 'a_' + parameter + ' => %(' + parameter + ')s,'

        query = query[:-1]
        
        query += ''');'''

        updated = db_wrapper.generic_manipulation(query, parameters)

        if updated:

            return jsonify({'message': 'Atualizado com sucesso'}), OK
        
        else:

            return jsonify({'message': 'Erro no servidor.'}), INTERNAL_SERVER_ERROR

    elif request.method == 'DELETE': 

        if id:

            query = '''CALL system_delete(%(id)s);'''

            parameters = {"id": id}

            deleted = db_wrapper.generic_manipulation(query, parameters)

            if deleted:

                return jsonify({'message': 'Eliminado com sucesso'}), OK
        
            else:

                return jsonify({'message': 'Erro no servidor.'}), INTERNAL_SERVER_ERROR
            
        else:

            return jsonify({'message': 'Parâmetros em falta'}), BAD_REQUEST
    
    else:

        return jsonify({'message': 'Metodo HTTP inválido'}), METHOD_NOT_ALLOWED
    
# !!! SENSOR !!!
@app.route("/sensor/<id>", methods=['GET', 'DELETE'])
@app.route("/sensor/", methods=['GET', 'POST', 'PUT'])
@auth_user
def sensor(id = None):

    if request.method == 'GET':

        if id:

            query = 'SELECT * FROM sensor_view(%(id)s);'
            parameters = {"id": id}
            data = db_wrapper.generic_select(query, parameters)

            if data:

                data = data[0]

        else:

            query = 'SELECT * FROM sensor_view;'
            data = db_wrapper.generic_select(query)

        if not data:

            return jsonify({'message': 'Nenhum sistema encontrado.'}), NOT_FOUND

        return jsonify(data), OK

    elif request.method == 'POST':

        parameters = request.get_json()

        received_parameters = ['sensor_type_id','system_id', 'inactivity_seconds']

        if not all(parameter in parameters for parameter in received_parameters):

            return jsonify({'message': 'Parâmetros em falta'}), BAD_REQUEST

        query = '''CALL sensor_insert(%(sensor_type_id)s, %(system_id)s, %(inactivity_seconds)s);'''

        inserted = db_wrapper.generic_manipulation(query, parameters)

        if inserted:

            return jsonify({'message': 'Inserido com sucesso'}), OK
        
        else:

            return jsonify({'message': 'Erro no servidor.'}), INTERNAL_SERVER_ERROR

    elif request.method == 'PUT':

        parameters = request.get_json()

        received_parameters = ['id']

        if not all(parameter in parameters for parameter in received_parameters):

            return jsonify({'message': 'Parâmetros em falta'}), BAD_REQUEST

        query = '''CALL sensor_update('''

        for parameter in parameters:

            query += 'a_' + parameter + ' => %(' + parameter + ')s,'

        query = query[:-1]
        
        query += ''');'''

        updated = db_wrapper.generic_manipulation(query, parameters)

        if updated:

            return jsonify({'message': 'Atualizado com sucesso'}), OK
        
        else:

            return jsonify({'message': 'Erro no servidor.'}), INTERNAL_SERVER_ERROR

    elif request.method == 'DELETE': 

        if id:

            query = '''CALL sensor_delete(%(id)s);'''

            parameters = {"id": id}

            deleted = db_wrapper.generic_manipulation(query, parameters)

            if deleted:

                return jsonify({'message': 'Eliminado com sucesso'}), OK
        
            else:

                return jsonify({'message': 'Erro no servidor.'}), INTERNAL_SERVER_ERROR
            
        else:

            return jsonify({'message': 'Parâmetros em falta'}), BAD_REQUEST
    
    else:

        return jsonify({'message': 'Metodo HTTP inválido'}), METHOD_NOT_ALLOWED
    
# !!! SENSOR TYPE !!!
@app.route("/sensor-type/<id>", methods=['GET', 'DELETE'])
@app.route("/sensor-type/", methods=['GET', 'POST', 'PUT'])
@auth_user
def sensor_type(id = None):

    if request.method == 'GET':

        if id:

            query = 'SELECT * FROM sensor_type_view(%(id)s);'
            parameters = {"id": id}
            data = db_wrapper.generic_select(query, parameters)

            if data:

                data = data[0]

        else:

            query = 'SELECT * FROM sensor_type_view;'
            data = db_wrapper.generic_select(query)

        if not data:

            return jsonify({'message': 'Nenhum tipo de sensor encontrado.'}), NOT_FOUND

        return jsonify(data), OK

    elif request.method == 'POST':

        parameters = request.get_json()

        received_parameters = ['type']

        if not all(parameter in parameters for parameter in received_parameters):

            return jsonify({'message': 'Parâmetros em falta'}), BAD_REQUEST

        query = '''CALL sensor_type_insert(%(type)s);'''

        inserted = db_wrapper.generic_manipulation(query, parameters)

        if inserted:

            return jsonify({'message': 'Inserido com sucesso'}), OK
        
        else:

            return jsonify({'message': 'Erro no servidor.'}), INTERNAL_SERVER_ERROR
        
    elif request.method == 'PUT':

        parameters = request.get_json()

        received_parameters = ['id']

        if not all(parameter in parameters for parameter in received_parameters):

            return jsonify({'message': 'Parâmetros em falta'}), BAD_REQUEST

        query = '''CALL sensor_type_update('''

        for parameter in parameters:

            query += 'a_' + parameter + ' => %(' + parameter + ')s,'

        query = query[:-1]
        
        query += ''');'''

        updated = db_wrapper.generic_manipulation(query, parameters)

        if updated:

            return jsonify({'message': 'Atualizado com sucesso'}), OK
        
        else:

            return jsonify({'message': 'Erro no servidor.'}), INTERNAL_SERVER_ERROR

    elif request.method == 'DELETE': 

        if id:

            query = '''CALL sensor_type_delete(%(id)s);'''

            parameters = {"id": id}

            deleted = db_wrapper.generic_manipulation(query, parameters)

            if deleted:

                return jsonify({'message': 'Eliminado com sucesso'}), OK
        
            else:

                return jsonify({'message': 'Erro no servidor.'}), INTERNAL_SERVER_ERROR
            
        else:

            return jsonify({'message': 'Parâmetros em falta'}), BAD_REQUEST
    
    else:

        return jsonify({'message': 'Metodo HTTP inválido'}), METHOD_NOT_ALLOWED
    
# !!! ACTUATOR !!!
@app.route("/actuator/<id>", methods=['GET', 'DELETE'])
@app.route("/actuator/", methods=['GET', 'POST', 'PUT'])
@auth_user
def actuator(id = None):

    if request.method == 'GET':

        if id:

            query = 'SELECT * FROM actuator_view(%(id)s);'
            parameters = {"id": id}
            data = db_wrapper.generic_select(query, parameters)

            if data:

                data = data[0]

        else:

            query = 'SELECT * FROM actuator_view;'
            data = db_wrapper.generic_select(query)

        if not data:

            return jsonify({'message': 'Nenhum atuador encontrado.'}), NOT_FOUND

        return jsonify(data), OK

    elif request.method == 'POST':

        parameters = request.get_json()

        received_parameters = ['system_id', 'inactivity_seconds']

        if not all(parameter in parameters for parameter in received_parameters):

            return jsonify({'message': 'Parâmetros em falta'}), BAD_REQUEST

        query = '''CALL actuator_insert(%(system_id)s, %(inactivity_seconds)s);'''

        inserted = db_wrapper.generic_manipulation(query, parameters)

        if inserted:

            return jsonify({'message': 'Inserido com sucesso'}), OK
        
        else:

            return jsonify({'message': 'Erro no servidor.'}), INTERNAL_SERVER_ERROR
        
    elif request.method == 'PUT':

        parameters = request.get_json()

        received_parameters = ['id']

        if not all(parameter in parameters for parameter in received_parameters):

            return jsonify({'message': 'Parâmetros em falta'}), BAD_REQUEST

        query = '''CALL actuator_update('''

        for parameter in parameters:

            query += 'a_' + parameter + ' => %(' + parameter + ')s,'

        query = query[:-1]
        
        query += ''');'''

        updated = db_wrapper.generic_manipulation(query, parameters)

        if updated:

            return jsonify({'message': 'Atualizado com sucesso'}), OK
        
        else:

            return jsonify({'message': 'Erro no servidor.'}), INTERNAL_SERVER_ERROR

    elif request.method == 'DELETE': 

        if id:

            query = '''CALL actuator_delete(%(id)s);'''

            parameters = {"id": id}

            deleted = db_wrapper.generic_manipulation(query, parameters)

            if deleted:

                return jsonify({'message': 'Eliminado com sucesso'}), OK
        
            else:

                return jsonify({'message': 'Erro no servidor.'}), INTERNAL_SERVER_ERROR
            
        else:

            return jsonify({'message': 'Parâmetros em falta'}), BAD_REQUEST
    
    else:

        return jsonify({'message': 'Metodo HTTP inválido'}), METHOD_NOT_ALLOWED
    
# !!! USER !!!
@app.route("/user/<id>", methods=['GET', 'DELETE'])
@app.route("/user/", methods=['GET', 'POST', 'PUT'])
@auth_user
def user(id = None):

    if request.method == 'GET':

        if id:

            query = 'SELECT * FROM user_view(%(id)s);'
            parameters = {"id": id}
            data = db_wrapper.generic_select(query, parameters)

            if data:

                data = data[0]

        else:

            query = 'SELECT * FROM user_view;'
            data = db_wrapper.generic_select(query)

        if not data:

            return jsonify({'message': 'Nenhum utilizador encontrado.'}), NOT_FOUND

        return jsonify(data), OK

    elif request.method == 'POST':

        parameters = request.get_json()

        received_parameters = ['name','email', 'password']

        if not all(parameter in parameters for parameter in received_parameters):

            return jsonify({'message': 'Parâmetros em falta'}), BAD_REQUEST

        query = '''CALL user_insert(%(name)s, %(email)s, %(password)s);'''

        inserted = db_wrapper.generic_manipulation(query, parameters)

        if inserted:

            return jsonify({'message': 'Inserido com sucesso'}), OK
        
        else:

            return jsonify({'message': 'Erro no servidor.'}), INTERNAL_SERVER_ERROR

    elif request.method == 'PUT':

        parameters = request.get_json()

        received_parameters = ['id']

        if not all(parameter in parameters for parameter in received_parameters):

            return jsonify({'message': 'Parâmetros em falta'}), BAD_REQUEST

        query = '''CALL user_update('''

        for parameter in parameters:

            query += 'a_' + parameter + ' => %(' + parameter + ')s,'

        query = query[:-1]
        
        query += ''');'''

        updated = db_wrapper.generic_manipulation(query, parameters)

        if updated:

            return jsonify({'message': 'Atualizado com sucesso'}), OK
        
        else:

            return jsonify({'message': 'Erro no servidor.'}), INTERNAL_SERVER_ERROR

    elif request.method == 'DELETE': 

        if id:

            query = '''CALL user_delete(%(id)s);'''

            parameters = {"id": id}

            deleted = db_wrapper.generic_manipulation(query, parameters)

            if deleted:

                return jsonify({'message': 'Eliminado com sucesso'}), OK
        
            else:

                return jsonify({'message': 'Erro no servidor.'}), INTERNAL_SERVER_ERROR
            
        else:

            return jsonify({'message': 'Parâmetros em falta'}), BAD_REQUEST
    
    else:

        return jsonify({'message': 'Metodo HTTP inválido'}), METHOD_NOT_ALLOWED

    

if __name__ == "__main__":
    app.run()