import  psycopg2, psycopg2.extras
import os, db_env

def generic_select(query, parameters = None):

    try:

        with psycopg2.connect("host=" + os.environ['HOST'] + " port=" + os.environ['PORT'] + " dbname=" + os.environ['DBNAME'] + " user=" + os.environ['USER'] + " password=" + os.environ['PASSWORD'], cursor_factory=psycopg2.extras.RealDictCursor) as conn:

            with conn.cursor() as cur:

                cur.execute(query, parameters)

                data = cur.fetchall()

        cur.close()
        conn.close()

        return data
    
    except Exception as e:

        print(e)
        return None


def generic_manipulation(query, parameters = None):

    try:

        with psycopg2.connect("host=" + os.environ['HOST'] + " port=" + os.environ['PORT'] + " dbname=" + os.environ['DBNAME'] + " user=" + os.environ['USER'] + " password=" + os.environ['PASSWORD'], cursor_factory=psycopg2.extras.RealDictCursor) as conn:

            with conn.cursor() as cur:

                cur.execute(query, parameters)
                conn.commit()

        cur.close()
        conn.close()

        return True
    
    except Exception as e:
        
        conn.rollback()
        print(e)
        return False