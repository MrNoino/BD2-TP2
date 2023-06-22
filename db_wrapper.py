import  psycopg2, psycopg2.extras
import os, http_codes
#import db_env

def generic_select(query, parameters = None):

    try:

        with psycopg2.connect("host=" + os.environ['HOST'] + " port=" + os.environ['PORT'] + " dbname=" + os.environ['DBNAME'] + " user=" + os.environ['USER'] + " password=" + os.environ['PASSWORD'], cursor_factory=psycopg2.extras.RealDictCursor) as conn:

            with conn.cursor() as cur:

                cur.execute(query, parameters)

                data = cur.fetchall()

        cur.close()
        conn.close()

        if not data:

            return {"code": http_codes.NOT_FOUND}

        return {"code": http_codes.OK, "data": data}
    
    except psycopg2.Error as e:

        error = e.pgerror.splitlines()[0]
        print(e)

        if '403' in error:

            return {'code': http_codes.FORBIDDEN}
        
        elif '404' in error:

            return {'code': http_codes.NOT_FOUND}
        
        elif '400' in error:

            return {'code': http_codes.BAD_REQUEST}
        
        elif '503' in error:

            return {'code': http_codes.SERVICE_UNAVAILABLE}
        
        return {'code': http_codes.INTERNAL_SERVER_ERROR}


def generic_manipulation(query, parameters = None):

    try:

        with psycopg2.connect("host=" + os.environ['HOST'] + " port=" + os.environ['PORT'] + " dbname=" + os.environ['DBNAME'] + " user=" + os.environ['USER'] + " password=" + os.environ['PASSWORD'], cursor_factory=psycopg2.extras.RealDictCursor) as conn:

            with conn.cursor() as cur:

                cur.execute(query, parameters)
                conn.commit()

        cur.close()
        conn.close()

        return {'code': http_codes.OK}
    
    except psycopg2.Error as e:
        
        conn.rollback()
        error = e.pgerror.splitlines()[0]
        print(e)

        if '403' in error:

            return {'code': http_codes.FORBIDDEN}
        

        elif '404' in error:

            return {'code': http_codes.NOT_FOUND}
        
        elif '400' in error:

            return {'code': http_codes.BAD_REQUEST}
        
        return {'code': http_codes.INTERNAL_SERVER_ERROR}
