helm repo add repo-operador-mariadb-ivan https://helm.mariadb.com/mariadb-operator
helm install mariadb-operator-crds repo-operador-mariadb-ivan/mariadb-operator-crds # Solo se monta 1 vez
helm pull --untar repo-operador-mariadb-ivan/mariadb-operator
helm install operador-mariadb-ivan repo-operador-mariadb-ivan/mariadb-operator -n mariadb-ivan --create-namespace -f mariadb-operator/values.yaml

