from flask import Flask, jsonify, request
import db_wrapper, jwt 
from functools import wraps
from datetime import datetime, timedelta
import os, env, http_codes

app = Flask(__name__)

# !!! AUTH !!!
def auth_user(func):

    @wraps(func)
    def verify_token(*args, **kwargs):

        if "Authorization" in request.headers:

            token = request.headers["Authorization"].split(" ")[1]

        else:

            return jsonify({'Erro': 'Token está em falta!'}), http_codes.BAD_REQUEST

        if not token:

            return jsonify({'Erro': 'Token está em falta!'}), http_codes.BAD_REQUEST

        try:

            decoded_token = jwt.decode(token, os.environ["SECRET_KEY"], algorithms=["HS256"])

            if(decoded_token["expiration"] < str(datetime.utcnow())):

                return jsonify({"Erro": "O Token expirou!"}), http_codes.FORBIDDEN

        except Exception as e:

            return jsonify({'Erro': str(e)}), http_codes.UNAUTHORIZED
        
        return func(*args, **kwargs)
    
    return verify_token


# !!! START !!!
@app.route("/")
def hello_world():

    return jsonify({"message": "Welcome To IOT API"}), http_codes.OK

# !!! LOGIN !!!
@app.post("/login/")
def login():

    parameters = request.get_json()

    received_parameters = ['email', 'password']

    if not all(parameter in parameters for parameter in received_parameters):

        return jsonify({'message': 'Pedido mal formado'}), http_codes.BAD_REQUEST

    query = '''SELECT * FROM login(%(email)s, %(password)s);'''

    response = db_wrapper.generic_select(query, parameters)

    if response["code"] == http_codes.OK:

        token = jwt.encode({
                    'id': response["data"][0]["id"],
                    'expiration': str(datetime.utcnow() + timedelta(weeks=5))
                }, os.environ["SECRET_KEY"])

        return jsonify({'token': token}), http_codes.OK
    
    elif response["code"] == http_codes.NOT_FOUND:

        return jsonify({'message': 'Credênciais inválidas'}), http_codes.NOT_FOUND
    
    else:

        return jsonify({'message': 'Erro no servidor'}), http_codes.INTERNAL_SERVER_ERROR


# !!! SYSTEM !!!
@app.route("/system/<id>/", methods=['GET', 'DELETE'])
@app.route("/system/", methods=['GET', 'POST', 'PUT'])
@auth_user
def system(id = None):

    token = request.headers["Authorization"].split(" ")[1]
    decoded_token = jwt.decode(token, os.environ["SECRET_KEY"], algorithms=["HS256"])

    if request.method == 'GET':

        if id:

            query = 'SELECT * FROM system_view(%(user_id)s, %(id)s);'
            parameters = {"user_id": decoded_token['id'], "id": id}
            response = db_wrapper.generic_select(query, parameters)

            if response["code"] == 200:

                response["data"] = response["data"][0]

        else:

            query = 'SELECT * FROM system_view(%(user_id)s);'
            parameters = {"user_id": decoded_token['id']}
            response = db_wrapper.generic_select(query, parameters)

        if response["code"] == http_codes.OK:

            return jsonify(response["data"]), http_codes.OK

        elif response["code"] == http_codes.NOT_FOUND:

            return jsonify({'message': 'Não encontrado'}), http_codes.NOT_FOUND
        
        elif response["code"] == http_codes.FORBIDDEN:

            return jsonify({'message': 'Acesso negado'}), http_codes.FORBIDDEN

        else:
            
            return jsonify({'message': 'Erro no servidor'}), http_codes.INTERNAL_SERVER_ERROR

    elif request.method == 'POST':

        parameters = request.get_json()

        received_parameters = ['location', 'property']

        if not all(parameter in parameters for parameter in received_parameters):

            return jsonify({'message': 'Pedido mal formado'}), http_codes.BAD_REQUEST

        query = '''CALL system_insert(%(location)s, %(property)s, %(owner_id)s);'''

        parameters.update({"owner_id": decoded_token['id']})

        response = db_wrapper.generic_manipulation(query, parameters)

        if response["code"] == http_codes.OK:

            return jsonify({'message': 'Inserido com sucesso'}), http_codes.CREATED
        
        elif response["code"] == http_codes.FORBIDDEN:

            return jsonify({'message': 'Acesso negado'}), http_codes.FORBIDDEN
        
        else:

            return jsonify({'message': 'Erro no servidor'}), http_codes.INTERNAL_SERVER_ERROR

    elif request.method == 'PUT':

        parameters = request.get_json()

        received_parameters = ['id']

        if not all(parameter in parameters for parameter in received_parameters):

            return jsonify({'message': 'Pedido mal formado'}), http_codes.BAD_REQUEST

        query = '''CALL system_update(%(user_id)s, '''

        for parameter in parameters:

            query += 'a_' + parameter + ' => %(' + parameter + ')s,'

        query = query[:-1]
        
        query += ''');'''

        parameters.update({"user_id": decoded_token['id']})

        response = db_wrapper.generic_manipulation(query, parameters)

        if response["code"] == http_codes.OK:

            return jsonify({'message': 'Atualizado com sucesso'}), http_codes.OK
        
        elif response["code"] == http_codes.FORBIDDEN:

            return jsonify({'message': 'Acesso negado'}), http_codes.FORBIDDEN
        
        elif response["code"] == http_codes.NOT_FOUND:

            return jsonify({'message': 'Não encontrado'}), http_codes.NOT_FOUND
        
        else:

            return jsonify({'message': 'Erro no servidor'}), http_codes.INTERNAL_SERVER_ERROR
        
    elif request.method == 'DELETE': 

        if id:

            query = '''CALL system_delete(%(user_id)s, %(id)s);'''

            parameters = {"id": id, "user_id": decoded_token["id"]}

            response = db_wrapper.generic_manipulation(query, parameters)

            if response["code"] == http_codes.OK:

                return jsonify({'message': 'Eliminado com sucesso'}), http_codes.OK
            
            elif response["code"] == http_codes.FORBIDDEN:

                return jsonify({'message': 'Acesso negado'}), http_codes.FORBIDDEN
            
            elif response["code"] == http_codes.NOT_FOUND:

                return jsonify({'message': 'Não encontrado'}), http_codes.NOT_FOUND
            
            else:

                return jsonify({'message': 'Erro no servidor'}), http_codes.INTERNAL_SERVER_ERROR
        else:

            return jsonify({'message': 'Pedido mal formado'}), http_codes.BAD_REQUEST
        
    else:

        return jsonify({'message': 'Metodo HTTP inválido'}), http_codes.METHOD_NOT_ALLOWED
    
# !!! SENSOR !!!
@app.route("/sensor/<id>/", methods=['GET', 'DELETE'])
@app.route("/sensor/", methods=['GET', 'POST', 'PUT'])
@auth_user
def sensor(id = None):

    token = request.headers["Authorization"].split(" ")[1]
    decoded_token = jwt.decode(token, os.environ["SECRET_KEY"], algorithms=["HS256"])

    if request.method == 'GET':

        if id:

            query = 'SELECT * FROM sensor_view(%(user_id)s, %(id)s);'
            parameters = {"user_id": decoded_token['id'], "id": id}
            response = db_wrapper.generic_select(query, parameters)

            if response["code"] == 200:

                response["data"] = response["data"][0]

        else:

            query = 'SELECT * FROM sensor_view(%(user_id)s);'
            parameters = {"user_id": decoded_token['id']}
            response = db_wrapper.generic_select(query, parameters)

        if response["code"] == http_codes.OK:

            return jsonify(response["data"]), http_codes.OK
        
        elif response["code"] == http_codes.FORBIDDEN:

            return jsonify({'message': 'Acesso negado'}), http_codes.FORBIDDEN
        
        elif response["code"] == http_codes.NOT_FOUND:

            return jsonify({'message': 'Não encontrado'}), http_codes.NOT_FOUND
        
        else:

            return jsonify({'message': 'Erro no servidor'}), http_codes.INTERNAL_SERVER_ERROR

    elif request.method == 'POST':

        parameters = request.get_json()

        received_parameters = ['sensor_type_id','system_id', 'inactivity_seconds']

        if not all(parameter in parameters for parameter in received_parameters):

            return jsonify({'message': 'Pedido mal formado'}), http_codes.BAD_REQUEST

        query = '''CALL sensor_insert(%(user_id)s, %(sensor_type_id)s, %(system_id)s, %(inactivity_seconds)s);'''

        parameters.update({"user_id": decoded_token['id']})

        response = db_wrapper.generic_manipulation(query, parameters)

        if response["code"] == http_codes.OK:

            return jsonify({'message': 'Inserido com sucesso'}), http_codes.CREATED
        
        elif response["code"] == http_codes.FORBIDDEN:

            return jsonify({'message': 'Operação não permitida'}), http_codes.FORBIDDEN

        else:

            return jsonify({'message': 'Erro no servidor'}), http_codes.INTERNAL_SERVER_ERROR

    elif request.method == 'PUT':

        parameters = request.get_json()

        received_parameters = ['id']

        if not all(parameter in parameters for parameter in received_parameters):

            return jsonify({'message': 'Pedido mal formado'}), http_codes.BAD_REQUEST

        query = '''CALL sensor_update(%(user_id)s,'''

        for parameter in parameters:

            query += 'a_' + parameter + ' => %(' + parameter + ')s,'

        query = query[:-1]
        
        query += ''');'''

        parameters.update({"user_id": decoded_token['id']})

        response = db_wrapper.generic_manipulation(query, parameters)

        if response["code"] == http_codes.OK:

            return jsonify({'message': 'Atualizado com sucesso'}), http_codes.OK
        
        elif response["code"] == http_codes.FORBIDDEN:

            return jsonify({'message': 'Acesso negado'}), http_codes.FORBIDDEN
        
        elif response["code"] == http_codes.NOT_FOUND:

            return jsonify({'message': 'Não encontrado'}), http_codes.NOT_FOUND
        
        else:

            return jsonify({'message': 'Erro no servidor'}), http_codes.INTERNAL_SERVER_ERROR

    elif request.method == 'DELETE': 

        if id:

            query = '''CALL sensor_delete(%(user_id)s, %(id)s);'''

            parameters = {"id": id, "user_id": decoded_token['id']}

            response = db_wrapper.generic_manipulation(query, parameters)

            if response["code"] == http_codes.OK:

                return jsonify({'message': 'Eliminado com sucesso'}), http_codes.OK
            
            elif response["code"] == http_codes.FORBIDDEN:

                return jsonify({'message': 'Acesso negado'}), http_codes.FORBIDDEN
            
            elif response["code"] == http_codes.NOT_FOUND:

                return jsonify({'message': 'Não encontrado'}), http_codes.NOT_FOUND
            
            else:

                return jsonify({'message': 'Erro no servidor'}), http_codes.INTERNAL_SERVER_ERROR
            
        else:

            return jsonify({'message': 'Pedido mal formado'}), http_codes.BAD_REQUEST
    
    else:

        return jsonify({'message': 'Metodo HTTP inválido'}), http_codes.METHOD_NOT_ALLOWED
    
# !!! SENSOR TYPE !!!
@app.route("/sensor-type/<id>/", methods=['GET', 'DELETE'])
@app.route("/sensor-type/", methods=['GET', 'POST', 'PUT'])
@auth_user
def sensor_type(id = None):

    if request.method == 'GET':

        if id:

            query = 'SELECT * FROM sensor_type_view(%(id)s);'
            parameters = {"id": id}
            response = db_wrapper.generic_select(query, parameters)

            if response["code"] == 200:

                response["data"] = response["data"][0]

        else:

            query = 'SELECT * FROM sensor_type_view;'
            response = db_wrapper.generic_select(query)

        if response["code"] == http_codes.OK:

            return jsonify(response["data"]), http_codes.OK

        elif response["code"] == http_codes.NOT_FOUND:

            return jsonify({'message': 'Não encontrado'}), http_codes.NOT_FOUND
        
        elif response["code"] == http_codes.FORBIDDEN:

            return jsonify({'message': 'Acesso negado'}), http_codes.FORBIDDEN

        else:
            
            return jsonify({'message': 'Erro no servidor'}), http_codes.INTERNAL_SERVER_ERROR

    elif request.method == 'POST':

        parameters = request.get_json()

        received_parameters = ['type']

        if not all(parameter in parameters for parameter in received_parameters):

            return jsonify({'message': 'Pedido mal formado'}), http_codes.BAD_REQUEST

        query = '''CALL sensor_type_insert(%(type)s);'''

        response = db_wrapper.generic_manipulation(query, parameters)

        if response["code"] == http_codes.OK:

            return jsonify({'message': 'Inserido com sucesso'}), http_codes.CREATED
        
        elif response["code"] == http_codes.FORBIDDEN:

            return jsonify({'message': 'Operação não permitida'}), http_codes.FORBIDDEN

        else:

            return jsonify({'message': 'Erro no servidor'}), http_codes.INTERNAL_SERVER_ERROR
        
    elif request.method == 'PUT':

        parameters = request.get_json()

        received_parameters = ['id']

        if not all(parameter in parameters for parameter in received_parameters):

            return jsonify({'message': 'Pedido mal formado'}), http_codes.BAD_REQUEST

        query = '''CALL sensor_type_update('''

        for parameter in parameters:

            query += 'a_' + parameter + ' => %(' + parameter + ')s,'

        query = query[:-1]
        
        query += ''');'''

        response = db_wrapper.generic_manipulation(query, parameters)

        if response["code"] == http_codes.OK:

            return jsonify({'message': 'Atualizado com sucesso'}), http_codes.OK
        
        elif response["code"] == http_codes.FORBIDDEN:

            return jsonify({'message': 'Acesso negado'}), http_codes.FORBIDDEN
        
        elif response["code"] == http_codes.NOT_FOUND:

            return jsonify({'message': 'Não encontrado'}), http_codes.NOT_FOUND
        
        else:

            return jsonify({'message': 'Erro no servidor'}), http_codes.INTERNAL_SERVER_ERROR

    elif request.method == 'DELETE': 

        if id:

            query = '''CALL sensor_type_delete(%(id)s);'''

            parameters = {"id": id}

            response = db_wrapper.generic_manipulation(query, parameters)

            if response["code"] == http_codes.OK:

                return jsonify({'message': 'Eliminado com sucesso'}), http_codes.OK
            
            elif response["code"] == http_codes.FORBIDDEN:

                return jsonify({'message': 'Acesso negado'}), http_codes.FORBIDDEN
            
            elif response["code"] == http_codes.NOT_FOUND:

                return jsonify({'message': 'Não encontrado'}), http_codes.NOT_FOUND
            
            else:

                return jsonify({'message': 'Erro no servidor'}), http_codes.INTERNAL_SERVER_ERROR
            
        else:

            return jsonify({'message': 'Pedido mal formado'}), http_codes.BAD_REQUEST
    
    else:

        return jsonify({'message': 'Metodo HTTP inválido'}), http_codes.METHOD_NOT_ALLOWED
    
# !!! SENSOR HISTORY !!!
@app.route("/sensor-history/<id>/", methods=['GET', 'DELETE'])
@app.route("/sensor-history/", methods=['GET', 'POST', 'PUT'])
@auth_user
def sensor_history(id = None):

    token = request.headers["Authorization"].split(" ")[1]
    decoded_token = jwt.decode(token, os.environ["SECRET_KEY"], algorithms=["HS256"])

    if request.method == 'GET':

        if id:

            query = 'SELECT * FROM sensor_history_view(%(user_id)s, %(id)s);'
            parameters = {"user_id": decoded_token["id"], "id": id}
            response = db_wrapper.generic_select(query, parameters)

        else:

            query = 'SELECT * FROM sensor_history_view(%(user_id)s);'
            parameters = {"user_id": decoded_token["id"]}
            response = db_wrapper.generic_select(query, parameters)

        if response["code"] == http_codes.OK:

            return jsonify(response["data"]), http_codes.OK
        
        elif response["code"] == http_codes.FORBIDDEN:

            return jsonify({'message': 'Acesso negado'}), http_codes.FORBIDDEN
        
        elif response["code"] == http_codes.NOT_FOUND:

            return jsonify({'message': 'Não encontrado'}), http_codes.NOT_FOUND
        
        else:

            return jsonify({'message': 'Erro no servidor'}), http_codes.INTERNAL_SERVER_ERROR

    elif request.method == 'POST':

        parameters = request.get_json()

        received_parameters = ['sensor_id', 'received_datetime', 'value']

        if not all(parameter in parameters for parameter in received_parameters):

            return jsonify({'message': 'Pedido mal formado'}), http_codes.BAD_REQUEST

        query = '''CALL sensor_history_insert(%(user_id)s, %(sensor_id)s, %(received_datetime)s, %(value)s);'''

        parameters.update({"user_id": decoded_token['id']})

        response = db_wrapper.generic_manipulation(query, parameters)

        if response["code"] == http_codes.OK:

            return jsonify({'message': 'Inserido com sucesso'}), http_codes.CREATED
        
        elif response["code"] == http_codes.FORBIDDEN:

            return jsonify({'message': 'Operação não permitida'}), http_codes.FORBIDDEN

        else:

            return jsonify({'message': 'Erro no servidor'}), http_codes.INTERNAL_SERVER_ERROR
        
    elif request.method == 'PUT':

        parameters = request.get_json()

        received_parameters = ['id']

        if not all(parameter in parameters for parameter in received_parameters):

            return jsonify({'message': 'Pedido mal formado'}), http_codes.BAD_REQUEST

        query = '''CALL sensor_history_update(%(user_id)s,'''

        for parameter in parameters:

            query += 'a_' + parameter + ' => %(' + parameter + ')s,'

        query = query[:-1]
        
        query += ''');'''

        parameters.update({"user_id": decoded_token['id']})

        response = db_wrapper.generic_manipulation(query, parameters)

        if response["code"] == http_codes.OK:

            return jsonify({'message': 'Atualizado com sucesso'}), http_codes.OK
        
        elif response["code"] == http_codes.FORBIDDEN:

            return jsonify({'message': 'Acesso negado'}), http_codes.FORBIDDEN
        
        elif response["code"] == http_codes.NOT_FOUND:

            return jsonify({'message': 'Não encontrado'}), http_codes.NOT_FOUND
        
        else:

            return jsonify({'message': 'Erro no servidor'}), http_codes.INTERNAL_SERVER_ERROR
        
    elif request.method == 'DELETE': 

        if id:

            query = '''CALL sensor_history_delete(%(user_id)s, %(id)s);'''

            parameters = {"id": id, "user_id": decoded_token["id"]}

            response = db_wrapper.generic_manipulation(query, parameters)

            if response["code"] == http_codes.OK:

                return jsonify({'message': 'Eliminado com sucesso'}), http_codes.OK
            
            elif response["code"] == http_codes.FORBIDDEN:

                return jsonify({'message': 'Acesso negado'}), http_codes.FORBIDDEN
            
            elif response["code"] == http_codes.NOT_FOUND:

                return jsonify({'message': 'Não encontrado'}), http_codes.NOT_FOUND
            
            else:

                return jsonify({'message': 'Erro no servidor'}), http_codes.INTERNAL_SERVER_ERROR
            
        else:

            return jsonify({'message': 'Pedido mal formado'}), http_codes.BAD_REQUEST
    
    else:

        return jsonify({'message': 'Metodo HTTP inválido'}), http_codes.METHOD_NOT_ALLOWED
    
# !!! ACTUATOR !!!
@app.route("/actuator/<id>/", methods=['GET', 'DELETE'])
@app.route("/actuator/", methods=['GET', 'POST', 'PUT'])
@auth_user
def actuator(id = None):

    token = request.headers["Authorization"].split(" ")[1]
    decoded_token = jwt.decode(token, os.environ["SECRET_KEY"], algorithms=["HS256"])

    if request.method == 'GET':

        if id:

            query = 'SELECT * FROM actuator_view(%(user_id)s, %(id)s);'
            parameters = {"user_id": decoded_token["id"], "id": id}
            response = db_wrapper.generic_select(query, parameters)

            if response["code"] == http_codes.OK:

                response["data"] = response["data"][0]

        else:

            query = 'SELECT * FROM actuator_view(%(user_id)s);'
            parameters = {"user_id": decoded_token["id"]}
            response = db_wrapper.generic_select(query, parameters)

        if response["code"] == http_codes.OK:

            return jsonify(response["data"]), http_codes.OK
        
        elif response["code"] == http_codes.FORBIDDEN:

            return jsonify({'message': 'Acesso negado'}), http_codes.FORBIDDEN
        
        elif response["code"] == http_codes.NOT_FOUND:

            return jsonify({'message': 'Não encontrado'}), http_codes.NOT_FOUND
        
        else:

            return jsonify({'message': 'Erro no servidor'}), http_codes.INTERNAL_SERVER_ERROR

    elif request.method == 'POST':

        parameters = request.get_json()

        received_parameters = ['system_id']

        if not all(parameter in parameters for parameter in received_parameters):

            return jsonify({'message': 'Pedido mal formado'}), http_codes.BAD_REQUEST

        query = '''CALL actuator_insert(%(user_id)s, %(system_id)s);'''

        parameters.update({"user_id": decoded_token['id']})

        response = db_wrapper.generic_manipulation(query, parameters)

        if response["code"] == http_codes.OK:

            return jsonify({'message': 'Inserido com sucesso'}), http_codes.CREATED
        
        elif response["code"] == http_codes.FORBIDDEN:

            return jsonify({'message': 'Operação não permitida'}), http_codes.FORBIDDEN

        else:

            return jsonify({'message': 'Erro no servidor'}), http_codes.INTERNAL_SERVER_ERROR
        
    elif request.method == 'PUT':

        parameters = request.get_json()

        received_parameters = ['id']

        if not all(parameter in parameters for parameter in received_parameters):

            return jsonify({'message': 'Pedido mal formado'}), http_codes.BAD_REQUEST

        query = '''CALL actuator_update(%(user_id)s,'''

        for parameter in parameters:

            query += 'a_' + parameter + ' => %(' + parameter + ')s,'

        query = query[:-1]
        
        query += ''');'''

        parameters.update({"user_id": decoded_token['id']})

        response = db_wrapper.generic_manipulation(query, parameters)

        if response["code"] == http_codes.OK:

            return jsonify({'message': 'Atualizado com sucesso'}), http_codes.OK
        
        elif response["code"] == http_codes.FORBIDDEN:

            return jsonify({'message': 'Acesso negado'}), http_codes.FORBIDDEN
        
        elif response["code"] == http_codes.NOT_FOUND:

            return jsonify({'message': 'Não encontrado'}), http_codes.NOT_FOUND
        
        else:

            return jsonify({'message': 'Erro no servidor'}), http_codes.INTERNAL_SERVER_ERROR

    elif request.method == 'DELETE': 

        if id:

            query = '''CALL actuator_delete(%(user_id)s, %(id)s);'''

            parameters = {"id": id, "user_id": decoded_token["id"]}

            response = db_wrapper.generic_manipulation(query, parameters)

            if response["code"] == http_codes.OK:

                return jsonify({'message': 'Eliminado com sucesso'}), http_codes.OK
            
            elif response["code"] == http_codes.FORBIDDEN:

                return jsonify({'message': 'Acesso negado'}), http_codes.FORBIDDEN
            
            elif response["code"] == http_codes.NOT_FOUND:

                return jsonify({'message': 'Não encontrado'}), http_codes.NOT_FOUND
            
            else:

                return jsonify({'message': 'Erro no servidor'}), http_codes.INTERNAL_SERVER_ERROR
            
        else:

            return jsonify({'message': 'Pedido mal formado'}), http_codes.BAD_REQUEST
    
    else:

        return jsonify({'message': 'Metodo HTTP inválido'}), http_codes.METHOD_NOT_ALLOWED
    
# !!! ACTUATOR HISTORY !!!
@app.route("/actuator-history/<id>/", methods=['GET', 'DELETE'])
@app.route("/actuator-history/", methods=['GET', 'POST', 'PUT'])
@auth_user
def actuator_history(id = None):

    token = request.headers["Authorization"].split(" ")[1]
    decoded_token = jwt.decode(token, os.environ["SECRET_KEY"], algorithms=["HS256"])

    if request.method == 'GET':

        if id:

            query = 'SELECT * FROM actuator_history_view(%(user_id)s, %(id)s);'
            parameters = {"user_id": decoded_token["id"], "id": id}
            response = db_wrapper.generic_select(query, parameters)

        else:

            query = 'SELECT * FROM actuator_history_view(%(user_id)s);'
            parameters = {"user_id": decoded_token["id"]}
            response = db_wrapper.generic_select(query, parameters)

        if response["code"] == http_codes.OK:

            return jsonify(response["data"]), http_codes.OK
        
        elif response["code"] == http_codes.FORBIDDEN:

            return jsonify({'message': 'Acesso negado'}), http_codes.FORBIDDEN
        
        elif response["code"] == http_codes.NOT_FOUND:

            return jsonify({'message': 'Não encontrado'}), http_codes.NOT_FOUND
        
        else:

            return jsonify({'message': 'Erro no servidor'}), http_codes.INTERNAL_SERVER_ERROR

    elif request.method == 'POST':

        parameters = request.get_json()

        received_parameters = ['actuator_id', 'action_datetime', 'action']

        if not all(parameter in parameters for parameter in received_parameters):

            return jsonify({'message': 'Pedido mal formado'}), http_codes.BAD_REQUEST

        query = '''CALL actuator_history_insert(%(user_id)s, %(actuator_id)s, %(action_datetime)s, %(action)s);'''

        parameters.update({"user_id": decoded_token['id']})

        response = db_wrapper.generic_manipulation(query, parameters)

        if response["code"] == http_codes.OK:

            return jsonify({'message': 'Inserido com sucesso'}), http_codes.CREATED
        
        elif response["code"] == http_codes.FORBIDDEN:

            return jsonify({'message': 'Operação não permitida'}), http_codes.FORBIDDEN

        else:

            return jsonify({'message': 'Erro no servidor'}), http_codes.INTERNAL_SERVER_ERROR
        
    elif request.method == 'PUT':

        parameters = request.get_json()

        received_parameters = ['id']

        if not all(parameter in parameters for parameter in received_parameters):

            return jsonify({'message': 'Pedido mal formado'}), http_codes.BAD_REQUEST

        query = '''CALL actuator_history_update(%(user_id)s,'''

        for parameter in parameters:

            query += 'a_' + parameter + ' => %(' + parameter + ')s,'

        query = query[:-1]
        
        query += ''');'''

        parameters.update({"user_id": decoded_token['id']})

        response = db_wrapper.generic_manipulation(query, parameters)

        if response["code"] == http_codes.OK:

            return jsonify({'message': 'Atualizado com sucesso'}), http_codes.OK
        
        elif response["code"] == http_codes.FORBIDDEN:

            return jsonify({'message': 'Acesso negado'}), http_codes.FORBIDDEN
        
        elif response["code"] == http_codes.NOT_FOUND:

            return jsonify({'message': 'Não encontrado'}), http_codes.NOT_FOUND
        
        else:

            return jsonify({'message': 'Erro no servidor'}), http_codes.INTERNAL_SERVER_ERROR
        
    elif request.method == 'DELETE': 

        if id:

            query = '''CALL actuator_history_delete(%(user_id)s, %(id)s);'''

            parameters = {"id": id, "user_id": decoded_token["id"]}

            response = db_wrapper.generic_manipulation(query, parameters)

            if response["code"] == http_codes.OK:

                return jsonify({'message': 'Eliminado com sucesso'}), http_codes.OK
            
            elif response["code"] == http_codes.FORBIDDEN:

                return jsonify({'message': 'Acesso negado'}), http_codes.FORBIDDEN
            
            elif response["code"] == http_codes.NOT_FOUND:

                return jsonify({'message': 'Não encontrado'}), http_codes.NOT_FOUND
            
            else:

                return jsonify({'message': 'Erro no servidor'}), http_codes.INTERNAL_SERVER_ERROR
            
        else:

            return jsonify({'message': 'Pedido mal formado'}), http_codes.BAD_REQUEST
    
    else:

        return jsonify({'message': 'Metodo HTTP inválido'}), http_codes.METHOD_NOT_ALLOWED
    
# !!! ALERT !!!
@app.route("/alert/<id>/", methods=['GET', 'DELETE'])
@app.route("/alert/", methods=['GET', 'POST', 'PUT'])
@auth_user
def alert(id = None):

    token = request.headers["Authorization"].split(" ")[1]
    decoded_token = jwt.decode(token, os.environ["SECRET_KEY"], algorithms=["HS256"])

    if request.method == 'GET':

        if id:

            query = 'SELECT * FROM alert_view(%(user_id)s, %(id)s);'
            parameters = {"user_id": decoded_token["id"], "id": id}
            response = db_wrapper.generic_select(query, parameters)

            if response["code"] == 200:

                response["data"] = response["data"][0]

        else:

            query = 'SELECT * FROM alert_view(%(user_id)s);'
            parameters = {"user_id": decoded_token["id"]}
            response = db_wrapper.generic_select(query, parameters)

        if response["code"] == http_codes.OK:

            return jsonify(response["data"]), http_codes.OK
        
        elif response["code"] == http_codes.FORBIDDEN:

            return jsonify({'message': 'Acesso negado'}), http_codes.FORBIDDEN
        
        elif response["code"] == http_codes.NOT_FOUND:

            return jsonify({'message': 'Não encontrado'}), http_codes.NOT_FOUND
        
        else:

            return jsonify({'message': 'Erro no servidor'}), http_codes.INTERNAL_SERVER_ERROR

    elif request.method == 'POST':

        parameters = request.get_json()

        received_parameters = ['sensor_id','rule_id', 'value', 'alert']

        if not all(parameter in parameters for parameter in received_parameters):

            return jsonify({'message': 'Pedido mal formado'}), http_codes.BAD_REQUEST

        query = '''CALL alert_insert(%(user_id)s, %(sensor_id)s, %(rule_id)s, %(value)s, %(alert)s);'''

        parameters.update({"user_id": decoded_token['id']})

        response = db_wrapper.generic_manipulation(query, parameters)

        if response["code"] == http_codes.OK:

            return jsonify({'message': 'Inserido com sucesso'}), http_codes.CREATED
        
        elif response["code"] == http_codes.FORBIDDEN:

            return jsonify({'message': 'Operação não permitida'}), http_codes.FORBIDDEN

        else:

            return jsonify({'message': 'Erro no servidor'}), http_codes.INTERNAL_SERVER_ERROR

    elif request.method == 'PUT':

        parameters = request.get_json()

        received_parameters = ['id']

        if not all(parameter in parameters for parameter in received_parameters):

            return jsonify({'message': 'Pedido mal formado'}), http_codes.BAD_REQUEST

        query = '''CALL alert_update(%(user_id)s,'''

        for parameter in parameters:

            query += 'a_' + parameter + ' => %(' + parameter + ')s,'

        query = query[:-1]
        
        query += ''');'''

        parameters.update({"user_id": decoded_token['id']})

        response = db_wrapper.generic_manipulation(query, parameters)

        if response["code"] == http_codes.OK:

            return jsonify({'message': 'Atualizado com sucesso'}), http_codes.OK
        
        elif response["code"] == http_codes.FORBIDDEN:

            return jsonify({'message': 'Acesso negado'}), http_codes.FORBIDDEN
        
        elif response["code"] == http_codes.NOT_FOUND:

            return jsonify({'message': 'Não encontrado'}), http_codes.NOT_FOUND
        
        else:

            return jsonify({'message': 'Erro no servidor'}), http_codes.INTERNAL_SERVER_ERROR

    elif request.method == 'DELETE': 

        if id:

            query = '''CALL alert_delete(%(user_id)s, %(id)s);'''

            parameters = {"id": id, "user_id": decoded_token["id"]}

            response = db_wrapper.generic_manipulation(query, parameters)

            if response["code"] == http_codes.OK:

                return jsonify({'message': 'Eliminado com sucesso'}), http_codes.OK
            
            elif response["code"] == http_codes.FORBIDDEN:

                return jsonify({'message': 'Acesso negado'}), http_codes.FORBIDDEN
            
            elif response["code"] == http_codes.NOT_FOUND:

                return jsonify({'message': 'Não encontrado'}), http_codes.NOT_FOUND
            
            else:

                return jsonify({'message': 'Erro no servidor'}), http_codes.INTERNAL_SERVER_ERROR
            
        else:

            return jsonify({'message': 'Pedido mal formado'}), http_codes.BAD_REQUEST
    
    else:

        return jsonify({'message': 'Metodo HTTP inválido'}), http_codes.METHOD_NOT_ALLOWED
    
# !!! RULE !!!
@app.get("/rule/<id>/")
@app.get("/rule/")
@auth_user
def rule(id = None):

    if id:

        query = 'SELECT * FROM rule_view(%(id)s);'
        parameters = {"id": id}
        response = db_wrapper.generic_select(query, parameters)

        if response["code"] == 200:

            response["data"] = response["data"][0]

    else:

        query = 'SELECT * FROM rule_view;'
        response = db_wrapper.generic_select(query)

    if response["code"] == http_codes.OK:

        return jsonify(response["data"]), http_codes.OK
    
    elif response["code"] == http_codes.FORBIDDEN:

        return jsonify({'message': 'Acesso negado'}), http_codes.FORBIDDEN
    
    elif response["code"] == http_codes.NOT_FOUND:

        return jsonify({'message': 'Não encontrado'}), http_codes.NOT_FOUND
    
    else:

        return jsonify({'message': 'Erro no servidor'}), http_codes.INTERNAL_SERVER_ERROR

# !!! ALERT HISTORY !!!
@app.route("/alert-history/<id>/", methods=['GET', 'DELETE'])
@app.route("/alert-history/", methods=['GET', 'POST', 'PUT'])
@auth_user
def alert_history(id = None):

    token = request.headers["Authorization"].split(" ")[1]
    decoded_token = jwt.decode(token, os.environ["SECRET_KEY"], algorithms=["HS256"])

    if request.method == 'GET':

        if id:

            query = 'SELECT * FROM alert_history_view(%(user_id)s, %(id)s);'
            parameters = {"user_id": decoded_token["id"], "id": id}
            response = db_wrapper.generic_select(query, parameters)

            if response["code"] == 200:

                response["data"] = response["data"][0]

        else:

            query = 'SELECT * FROM alert_history_view(%(user_id)s);'
            parameters = {"user_id": decoded_token["id"]}
            response = db_wrapper.generic_select(query, parameters)

        if response["code"] == http_codes.OK:

            return jsonify(response["data"]), http_codes.OK
        
        elif response["code"] == http_codes.FORBIDDEN:

            return jsonify({'message': 'Acesso negado'}), http_codes.FORBIDDEN
        
        elif response["code"] == http_codes.NOT_FOUND:

            return jsonify({'message': 'Não encontrado'}), http_codes.NOT_FOUND
        
        else:

            return jsonify({'message': 'Erro no servidor'}), http_codes.INTERNAL_SERVER_ERROR

    elif request.method == 'POST':

        parameters = request.get_json()

        received_parameters = ['alert_id','alert_datetime']

        if not all(parameter in parameters for parameter in received_parameters):

            return jsonify({'message': 'Pedido mal formado'}), http_codes.BAD_REQUEST

        query = '''CALL alert_history_insert(%(user_id)s, %(alert_id)s, %(alert_datetime)s);'''

        parameters.update({"user_id": decoded_token['id']})

        response = db_wrapper.generic_manipulation(query, parameters)

        if response["code"] == http_codes.OK:

            return jsonify({'message': 'Inserido com sucesso'}), http_codes.CREATED
        
        elif response["code"] == http_codes.FORBIDDEN:

            return jsonify({'message': 'Operação não permitida'}), http_codes.FORBIDDEN

        else:

            return jsonify({'message': 'Erro no servidor'}), http_codes.INTERNAL_SERVER_ERROR

    elif request.method == 'PUT':

        parameters = request.get_json()

        received_parameters = ['id']

        if not all(parameter in parameters for parameter in received_parameters):

            return jsonify({'message': 'Pedido mal formado'}), http_codes.BAD_REQUEST

        query = '''CALL alert_history_update(%(user_id)s,'''

        for parameter in parameters:

            query += 'a_' + parameter + ' => %(' + parameter + ')s,'

        query = query[:-1]
        
        query += ''');'''

        parameters.update({"user_id": decoded_token['id']})

        response = db_wrapper.generic_manipulation(query, parameters)

        if response["code"] == http_codes.OK:

            return jsonify({'message': 'Atualizado com sucesso'}), http_codes.OK
        
        elif response["code"] == http_codes.FORBIDDEN:

            return jsonify({'message': 'Acesso negado'}), http_codes.FORBIDDEN
        
        elif response["code"] == http_codes.NOT_FOUND:

            return jsonify({'message': 'Não encontrado'}), http_codes.NOT_FOUND
        
        else:

            return jsonify({'message': 'Erro no servidor'}), http_codes.INTERNAL_SERVER_ERROR

    elif request.method == 'DELETE': 

        if id:

            query = '''CALL alert_history_delete(%(user_id)s, %(id)s);'''

            parameters = {"id": id, "user_id": decoded_token["id"]}

            response = db_wrapper.generic_manipulation(query, parameters)

            if response["code"] == http_codes.OK:

                return jsonify({'message': 'Eliminado com sucesso'}), http_codes.OK
            
            elif response["code"] == http_codes.FORBIDDEN:

                return jsonify({'message': 'Acesso negado'}), http_codes.FORBIDDEN
            
            elif response["code"] == http_codes.NOT_FOUND:

                return jsonify({'message': 'Não encontrado'}), http_codes.NOT_FOUND
            
            else:

                return jsonify({'message': 'Erro no servidor'}), http_codes.INTERNAL_SERVER_ERROR
            
        else:

            return jsonify({'message': 'Pedido mal formado'}), http_codes.BAD_REQUEST
    
    else:

        return jsonify({'message': 'Metodo HTTP inválido'}), http_codes.METHOD_NOT_ALLOWED

# !!! ALERT USER !!!
@app.route("/alert-user/<alert_history_id>/", methods=['GET', 'DELETE'])
@app.route("/alert-user/", methods=['GET', 'POST', 'PUT'])
@auth_user
def alert_user(alert_history_id = None):

    token = request.headers["Authorization"].split(" ")[1]
    decoded_token = jwt.decode(token, os.environ["SECRET_KEY"], algorithms=["HS256"])

    if request.method == 'GET':

        if alert_history_id:

            query = 'SELECT * FROM alert_user_view(%(alert_history_id)s, %(user_id)s);'
            parameters = {"alert_hisotry_id": alert_history_id, "user_id": decoded_token["id"]}
            response = db_wrapper.generic_select(query, parameters)

            if response["code"] == 200:

                response["data"] = response["data"][0]

        else:

            query = 'SELECT * FROM alert_user_view(%(user_id)s);'
            parameters = {"user_id": decoded_token["id"]}
            response = db_wrapper.generic_select(query, parameters)

        if response["code"] == http_codes.OK:

            return jsonify(response["data"]), http_codes.OK
        
        elif response["code"] == http_codes.FORBIDDEN:

            return jsonify({'message': 'Acesso negado'}), http_codes.FORBIDDEN
        
        elif response["code"] == http_codes.NOT_FOUND:

            return jsonify({'message': 'Não encontrado'}), http_codes.NOT_FOUND
        
        else:

            return jsonify({'message': 'Erro no servidor'}), http_codes.INTERNAL_SERVER_ERROR

    elif request.method == 'POST':

        parameters = request.get_json()

        received_parameters = ['alert_history_id', 'see_datetime']

        if not all(parameter in parameters for parameter in received_parameters):

            return jsonify({'message': 'Pedido mal formado'}), http_codes.BAD_REQUEST

        query = '''CALL alert_user_insert(%(alert_history_id)s, %(user_id)s, %(see_datetime)s);'''

        parameters.update({"user_id": decoded_token['id']})

        response = db_wrapper.generic_manipulation(query, parameters)

        if response["code"] == http_codes.OK:

            return jsonify({'message': 'Inserido com sucesso'}), http_codes.CREATED
        
        elif response["code"] == http_codes.FORBIDDEN:

            return jsonify({'message': 'Operação não permitida'}), http_codes.FORBIDDEN

        else:

            return jsonify({'message': 'Erro no servidor'}), http_codes.INTERNAL_SERVER_ERROR

    elif request.method == 'PUT':

        parameters = request.get_json()

        received_parameters = ['alert_history_id']

        if not all(parameter in parameters for parameter in received_parameters):

            return jsonify({'message': 'Pedido mal formado'}), http_codes.BAD_REQUEST

        query = '''CALL alert_user_update(a_user_id => %(user_id)s,'''

        for parameter in parameters:

            query += 'a_' + parameter + ' => %(' + parameter + ')s,'

        query = query[:-1]
        
        query += ''');'''

        parameters.update({"user_id": decoded_token['id']})

        response = db_wrapper.generic_manipulation(query, parameters)

        if response["code"] == http_codes.OK:

            return jsonify({'message': 'Atualizado com sucesso'}), http_codes.OK
        
        elif response["code"] == http_codes.FORBIDDEN:

            return jsonify({'message': 'Acesso negado'}), http_codes.FORBIDDEN
        
        elif response["code"] == http_codes.NOT_FOUND:

            return jsonify({'message': 'Não encontrado'}), http_codes.NOT_FOUND
        
        else:

            return jsonify({'message': 'Erro no servidor'}), http_codes.INTERNAL_SERVER_ERROR

    elif request.method == 'DELETE': 

        if alert_history_id:

            query = '''CALL alert_user_delete(%(owner_id)s, %(alert_history_id)s, %(user_id)s);'''

            parameters = {"alert_history_id": alert_history_id, "owner_id": decoded_token["id"], "user_id": decoded_token["id"]}

            response = db_wrapper.generic_manipulation(query, parameters)

            if response["code"] == http_codes.OK:

                return jsonify({'message': 'Eliminado com sucesso'}), http_codes.OK
            
            elif response["code"] == http_codes.FORBIDDEN:

                return jsonify({'message': 'Acesso negado'}), http_codes.FORBIDDEN
            
            elif response["code"] == http_codes.NOT_FOUND:

                return jsonify({'message': 'Não encontrado'}), http_codes.NOT_FOUND
            
            else:

                return jsonify({'message': 'Erro no servidor'}), http_codes.INTERNAL_SERVER_ERROR
            
        else:

            return jsonify({'message': 'Pedido mal formado'}), http_codes.BAD_REQUEST
    
    else:

        return jsonify({'message': 'Metodo HTTP inválido'}), http_codes.METHOD_NOT_ALLOWED
    
# !!! USER !!!
@app.route("/user/<id>/", methods=['GET', 'DELETE'])
@app.route("/user/", methods=['GET', 'POST', 'PUT'])
@auth_user
def user(id = None):

    token = request.headers["Authorization"].split(" ")[1]
    decoded_token = jwt.decode(token, os.environ["SECRET_KEY"], algorithms=["HS256"])

    if request.method == 'GET':

        if id:

            query = 'SELECT * FROM user_view(%(user_id)s, %(id)s);'
            parameters = {"user_id": decoded_token["id"], "id": id}
            response = db_wrapper.generic_select(query, parameters)

        else:

            query = 'SELECT * FROM user_view(%(id)s);'
            parameters = {"id": decoded_token["id"]}
            response = db_wrapper.generic_select(query, parameters)

        if response["code"] == http_codes.OK:

            response["data"] = response["data"][0]

            return jsonify(response["data"]), http_codes.OK
        
        elif response["code"] == http_codes.FORBIDDEN:

            return jsonify({'message': 'Acesso negado'}), http_codes.FORBIDDEN
        
        elif response["code"] == http_codes.NOT_FOUND:

            return jsonify({'message': 'Não encontrado'}), http_codes.NOT_FOUND
        
        else:

            return jsonify({'message': 'Erro no servidor'}), http_codes.INTERNAL_SERVER_ERROR

    elif request.method == 'POST':

        parameters = request.get_json()

        received_parameters = ['name','email', 'password']

        if not all(parameter in parameters for parameter in received_parameters):

            return jsonify({'message': 'Pedido mal formado'}), http_codes.BAD_REQUEST

        query = '''CALL user_insert(%(name)s, %(email)s, %(password)s);'''

        response = db_wrapper.generic_manipulation(query, parameters)

        if response["code"] == http_codes.OK:

            return jsonify({'message': 'Inserido com sucesso'}), http_codes.CREATED
        
        elif response["code"] == http_codes.FORBIDDEN:

            return jsonify({'message': 'Operação não permitida'}), http_codes.FORBIDDEN

        else:

            return jsonify({'message': 'Erro no servidor'}), http_codes.INTERNAL_SERVER_ERROR

    elif request.method == 'PUT':

        parameters = request.get_json()

        query = '''CALL user_update(%(user_id)s,'''

        for parameter in parameters:

            query += 'a_' + parameter + ' => %(' + parameter + ')s,'

        query = query[:-1]
        
        query += ''');'''

        parameters.update({"user_id": decoded_token['id']})

        response = db_wrapper.generic_manipulation(query, parameters)

        if response["code"] == http_codes.OK:

            return jsonify({'message': 'Atualizado com sucesso'}), http_codes.OK
        
        elif response["code"] == http_codes.FORBIDDEN:

            return jsonify({'message': 'Acesso negado'}), http_codes.FORBIDDEN
        
        elif response["code"] == http_codes.NOT_FOUND:

            return jsonify({'message': 'Não encontrado'}), http_codes.NOT_FOUND
        
        else:

            return jsonify({'message': 'Erro no servidor'}), http_codes.INTERNAL_SERVER_ERROR

    elif request.method == 'DELETE': 

        if id:

            query = '''CALL user_delete(%(id)s);'''

            parameters = {"id": decoded_token["id"]}

            response = db_wrapper.generic_manipulation(query, parameters)

            if response["code"] == http_codes.OK:

                return jsonify({'message': 'Eliminado com sucesso'}), http_codes.OK
            
            elif response["code"] == http_codes.FORBIDDEN:

                return jsonify({'message': 'Acesso negado'}), http_codes.FORBIDDEN
            
            elif response["code"] == http_codes.NOT_FOUND:

                return jsonify({'message': 'Não encontrado'}), http_codes.NOT_FOUND
            
            else:

                return jsonify({'message': 'Erro no servidor'}), http_codes.INTERNAL_SERVER_ERROR
            
        else:

            return jsonify({'message': 'Pedido mal formado'}), http_codes.BAD_REQUEST
    
    else:

        return jsonify({'message': 'Metodo HTTP inválido'}), http_codes.METHOD_NOT_ALLOWED

    

if __name__ == "__main__":
    app.run()