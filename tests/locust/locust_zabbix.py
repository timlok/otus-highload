from locust import HttpLocust, TaskSet

#запуск
#locust -f locust_zabbix.py --host=http://10.51.21.56:8080
#
#на всякий случай гостевая ссылка
#http://10.51.21.56:8080/zabbix/index.php?enter=guest


def index(l):
    l.client.get("/zabbix/index.php?enter=guest")

def graphs(l):
    l.client.get("/zabbix/screens.php?elementid=23")

def dashboard(l):
    l.client.get("/zabbix/zabbix.php?action=dashboard.view&dashboardid=1")



class UserBehavior(TaskSet):
    tasks = {graphs: 1, dashboard: 1}

    def on_start(self):
        index(self)

    def on_stop(self):
        graphs(self)

class WebsiteUser(HttpLocust):
    task_set = UserBehavior
    min_wait = 5000
    max_wait = 9000
