Name:         backups.k8s.mariadb.com
Namespace:    
Labels:       app.kubernetes.io/managed-by=Helm
Annotations:  controller-gen.kubebuilder.io/version: v0.18.0
              meta.helm.sh/release-name: mariadb-operator-crds
              meta.helm.sh/release-namespace: alberto-mariadb
API Version:  apiextensions.k8s.io/v1
Kind:         CustomResourceDefinition
Metadata:
  Creation Timestamp:  2025-09-08T16:23:35Z
  Generation:          1
  Resource Version:    1664542
  UID:                 5e4f3392-c251-47dc-ad07-a4bc9c284430
Spec:
  Conversion:
    Strategy:  None
  Group:       k8s.mariadb.com
  Names:
    Kind:       Backup
    List Kind:  BackupList
    Plural:     backups
    Short Names:
      bmdb
    Singular:  backup
  Scope:       Namespaced
  Versions:
    Additional Printer Columns:
      Json Path:  .status.conditions[?(@.type=="Complete")].status
      Name:       Complete
      Type:       string
      Json Path:  .status.conditions[?(@.type=="Complete")].message
      Name:       Status
      Type:       string
      Json Path:  .spec.mariaDbRef.name
      Name:       MariaDB
      Type:       string
      Json Path:  .metadata.creationTimestamp
      Name:       Age
      Type:       date
    Name:         v1alpha1
    Schema:
      openAPIV3Schema:
        Description:  Backup is the Schema for the backups API. It is used to define backup jobs and its storage.
        Properties:
          API Version:
            Description:  APIVersion defines the versioned schema of this representation of an object.
Servers should convert recognized schemas to the latest internal value, and
may reject unrecognized values.
More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources
            Type:  string
          Kind:
            Description:  Kind is a string value representing the REST resource this object represents.
Servers may infer this from the endpoint the client submits requests to.
Cannot be updated.
In CamelCase.
More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds
            Type:  string
          Metadata:
            Type:  object
          Spec:
            Description:  BackupSpec defines the desired state of Backup
            Properties:
              Affinity:
                Description:  Affinity to be used in the Pod.
                Properties:
                  Anti Affinity Enabled:
                    Description:  AntiAffinityEnabled configures PodAntiAffinity so each Pod is scheduled in a different Node, enabling HA.
Make sure you have at least as many Nodes available as the replicas to not end up with unscheduled Pods.
                    Type:  boolean
                  Node Affinity:
                    Description:  Refer to the Kubernetes docs: https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#nodeaffinity-v1-core
                    Properties:
                      Preferred During Scheduling Ignored During Execution:
                        Items:
                          Description:  Refer to the Kubernetes docs: https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#preferredschedulingterm-v1-core
                          Properties:
                            Preference:
                              Description:  Refer to the Kubernetes docs: https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#nodeselectorterm-v1-core
                              Properties:
                                Match Expressions:
                                  Items:
                                    Description:  Refer to the Kubernetes docs: https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#nodeselectorrequirement-v1-core
                                    Properties:
                                      Key:
                                        Type:  string
                                      Operator:
                                        Description:  A node selector operator is the set of operators that can be used in
a node selector requirement.
                                        Type:  string
                                      Values:
                                        Items:
                                          Type:                        string
                                        Type:                          array
                                        X - Kubernetes - List - Type:  atomic
                                    Required:
                                      key
                                      operator
                                    Type:                        object
                                  Type:                          array
                                  X - Kubernetes - List - Type:  atomic
                                Match Fields:
                                  Items:
                                    Description:  Refer to the Kubernetes docs: https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#nodeselectorrequirement-v1-core
                                    Properties:
                                      Key:
                                        Type:  string
                                      Operator:
                                        Description:  A node selector operator is the set of operators that can be used in
a node selector requirement.
                                        Type:  string
                                      Values:
                                        Items:
                                          Type:                        string
                                        Type:                          array
                                        X - Kubernetes - List - Type:  atomic
                                    Required:
                                      key
                                      operator
                                    Type:                        object
                                  Type:                          array
                                  X - Kubernetes - List - Type:  atomic
                              Type:                              object
                            Weight:
                              Format:  int32
                              Type:    integer
                          Required:
                            preference
                            weight
                          Type:                        object
                        Type:                          array
                        X - Kubernetes - List - Type:  atomic
                      Required During Scheduling Ignored During Execution:
                        Description:  Refer to the Kubernetes docs: https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#nodeselector-v1-core
                        Properties:
                          Node Selector Terms:
                            Items:
                              Description:  Refer to the Kubernetes docs: https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#nodeselectorterm-v1-core
                              Properties:
                                Match Expressions:
                                  Items:
                                    Description:  Refer to the Kubernetes docs: https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#nodeselectorrequirement-v1-core
                                    Properties:
                                      Key:
                                        Type:  string
                                      Operator:
                                        Description:  A node selector operator is the set of operators that can be used in
a node selector requirement.
                                        Type:  string
                                      Values:
                                        Items:
                                          Type:                        string
                                        Type:                          array
                                        X - Kubernetes - List - Type:  atomic
                                    Required:
                                      key
                                      operator
                                    Type:                        object
                                  Type:                          array
                                  X - Kubernetes - List - Type:  atomic
                                Match Fields:
                                  Items:
                                    Description:  Refer to the Kubernetes docs: https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#nodeselectorrequirement-v1-core
                                    Properties:
                                      Key:
                                        Type:  string
                                      Operator:
                                        Description:  A node selector operator is the set of operators that can be used in
a node selector requirement.
                                        Type:  string
                                      Values:
                                        Items:
                                          Type:                        string
                                        Type:                          array
                                        X - Kubernetes - List - Type:  atomic
                                    Required:
                                      key
                                      operator
                                    Type:                        object
                                  Type:                          array
                                  X - Kubernetes - List - Type:  atomic
                              Type:                              object
                            Type:                                array
                            X - Kubernetes - List - Type:        atomic
                        Required:
                          nodeSelectorTerms
                        Type:  object
                    Type:      object
                  Pod Anti Affinity:
                    Description:  Refer to the Kubernetes docs: https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#podantiaffinity-v1-core.
                    Properties:
                      Preferred During Scheduling Ignored During Execution:
                        Items:
                          Description:  Refer to the Kubernetes docs: https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#weightedpodaffinityterm-v1-core.
                          Properties:
                            Pod Affinity Term:
                              Description:  Refer to the Kubernetes docs: https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#podaffinityterm-v1-core.
                              Properties:
                                Label Selector:
                                  Description:  Refer to the Kubernetes docs: https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#labelselector-v1-meta
                                  Properties:
                                    Match Expressions:
                                      Items:
                                        Description:  Refer to the Kubernetes docs: https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#labelselectorrequirement-v1-meta
                                        Properties:
                                          Key:
                                            Type:  string
                                          Operator:
                                            Description:  A label selector operator is the set of operators that can be used in a selector requirement.
                                            Type:         string
                                          Values:
                                            Items:
                                              Type:                        string
                                            Type:                          array
                                            X - Kubernetes - List - Type:  atomic
                                        Required:
                                          key
                                          operator
                                        Type:                        object
                                      Type:                          array
                                      X - Kubernetes - List - Type:  atomic
                                    Match Labels:
                                      Additional Properties:
                                        Type:  string
                                      Type:    object
                                  Type:        object
                                Topology Key:
                                  Type:  string
                              Required:
                                topologyKey
                              Type:  object
                            Weight:
                              Format:  int32
                              Type:    integer
                          Required:
                            podAffinityTerm
                            weight
                          Type:                        object
                        Type:                          array
                        X - Kubernetes - List - Type:  atomic
                      Required During Scheduling Ignored During Execution:
                        Items:
                          Description:  Refer to the Kubernetes docs: https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#podaffinityterm-v1-core.
                          Properties:
                            Label Selector:
                              Description:  Refer to the Kubernetes docs: https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#labelselector-v1-meta
                              Properties:
                                Match Expressions:
                                  Items:
                                    Description:  Refer to the Kubernetes docs: https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#labelselectorrequirement-v1-meta
                                    Properties:
                                      Key:
                                        Type:  string
                                      Operator:
                                        Description:  A label selector operator is the set of operators that can be used in a selector requirement.
                                        Type:         string
                                      Values:
                                        Items:
                                          Type:                        string
                                        Type:                          array
                                        X - Kubernetes - List - Type:  atomic
                                    Required:
                                      key
                                      operator
                                    Type:                        object
                                  Type:                          array
                                  X - Kubernetes - List - Type:  atomic
                                Match Labels:
                                  Additional Properties:
                                    Type:  string
                                  Type:    object
                              Type:        object
                            Topology Key:
                              Type:  string
                          Required:
                            topologyKey
                          Type:                        object
                        Type:                          array
                        X - Kubernetes - List - Type:  atomic
                    Type:                              object
                Type:                                  object
              Args:
                Description:  Args to be used in the Container.
                Items:
                  Type:  string
                Type:    array
              Backoff Limit:
                Description:  BackoffLimit defines the maximum number of attempts to successfully take a Backup.
                Format:       int32
                Type:         integer
              Compression:
                Description:  Compression algorithm to be used in the Backup.
                Enum:
                  none
                  bzip2
                  gzip
                Type:  string
              Databases:
                Description:  Databases defines the logical databases to be backed up. If not provided, all databases are backed up.
                Items:
                  Type:  string
                Type:    array
              Failed Jobs History Limit:
                Description:  FailedJobsHistoryLimit defines the maximum number of failed Jobs to be displayed.
                Format:       int32
                Minimum:      0
                Type:         integer
              Ignore Global Priv:
                Description:  IgnoreGlobalPriv indicates to ignore the mysql.global_priv in backups.
If not provided, it will default to true when the referred MariaDB instance has Galera enabled and otherwise to false.
See: https://github.com/mariadb-operator/mariadb-operator/issues/556
                Type:  boolean
              Image Pull Secrets:
                Description:  ImagePullSecrets is the list of pull Secrets to be used to pull the image.
                Items:
                  Description:  Refer to the Kubernetes docs: https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#localobjectreference-v1-core.
                  Properties:
                    Name:
                      Default:  
                      Type:     string
                  Type:         object
                Type:           array
              Inherit Metadata:
                Description:  InheritMetadata defines the metadata to be inherited by children resources.
                Properties:
                  Annotations:
                    Additional Properties:
                      Type:       string
                    Description:  Annotations to be added to children resources.
                    Type:         object
                  Labels:
                    Additional Properties:
                      Type:       string
                    Description:  Labels to be added to children resources.
                    Type:         object
                Type:             object
              Log Level:
                Default:      info
                Description:  LogLevel to be used n the Backup Job. It defaults to 'info'.
                Type:         string
              Maria Db Ref:
                Description:  MariaDBRef is a reference to a MariaDB object.
                Properties:
                  Name:
                    Type:  string
                  Namespace:
                    Type:  string
                  Wait For It:
                    Default:      true
                    Description:  WaitForIt indicates whether the controller using this reference should wait for MariaDB to be ready.
                    Type:         boolean
                Type:             object
              Max Retention:
                Description:  MaxRetention defines the retention policy for backups. Old backups will be cleaned up by the Backup Job.
It defaults to 30 days.
                Type:  string
              Node Selector:
                Additional Properties:
                  Type:       string
                Description:  NodeSelector to be used in the Pod.
                Type:         object
              Pod Metadata:
                Description:  PodMetadata defines extra metadata for the Pod.
                Properties:
                  Annotations:
                    Additional Properties:
                      Type:       string
                    Description:  Annotations to be added to children resources.
                    Type:         object
                  Labels:
                    Additional Properties:
                      Type:       string
                    Description:  Labels to be added to children resources.
                    Type:         object
                Type:             object
              Pod Security Context:
                Description:  SecurityContext holds pod-level security attributes and common container settings.
                Properties:
                  App Armor Profile:
                    Description:  AppArmorProfile defines a pod or container's AppArmor settings.
                    Properties:
                      Localhost Profile:
                        Description:  localhostProfile indicates a profile loaded on the node that should be used.
The profile must be preconfigured on the node to work.
Must match the loaded name of the profile.
Must be set if and only if type is "Localhost".
                        Type:  string
                      Type:
                        Description:  type indicates which kind of AppArmor profile will be applied.
Valid options are:
  Localhost - a profile pre-loaded on the node.
  RuntimeDefault - the container runtime's default profile.
  Unconfined - no AppArmor enforcement.
                        Type:  string
                    Required:
                      type
                    Type:  object
                  Fs Group:
                    Format:  int64
                    Type:    integer
                  Fs Group Change Policy:
                    Description:  PodFSGroupChangePolicy holds policies that will be used for applying fsGroup to a volume
when volume is mounted.
                    Type:  string
                  Run As Group:
                    Format:  int64
                    Type:    integer
                  Run As Non Root:
                    Type:  boolean
                  Run As User:
                    Format:  int64
                    Type:    integer
                  Se Linux Options:
                    Description:  SELinuxOptions are the labels to be applied to the container
                    Properties:
                      Level:
                        Description:  Level is SELinux level label that applies to the container.
                        Type:         string
                      Role:
                        Description:  Role is a SELinux role label that applies to the container.
                        Type:         string
                      Type:
                        Description:  Type is a SELinux type label that applies to the container.
                        Type:         string
                      User:
                        Description:  User is a SELinux user label that applies to the container.
                        Type:         string
                    Type:             object
                  Seccomp Profile:
                    Description:  SeccompProfile defines a pod/container's seccomp profile settings.
Only one profile source may be set.
                    Properties:
                      Localhost Profile:
                        Description:  localhostProfile indicates a profile defined in a file on the node should be used.
The profile must be preconfigured on the node to work.
Must be a descending path, relative to the kubelet's configured seccomp profile location.
Must be set if type is "Localhost". Must NOT be set for any other type.
                        Type:  string
                      Type:
                        Description:  type indicates which kind of seccomp profile will be applied.
Valid options are:

Localhost - a profile defined in a file on the node should be used.
RuntimeDefault - the container runtime default profile should be used.
Unconfined - no profile should be applied.
                        Type:  string
                    Required:
                      type
                    Type:  object
                  Supplemental Groups:
                    Items:
                      Format:                      int64
                      Type:                        integer
                    Type:                          array
                    X - Kubernetes - List - Type:  atomic
                Type:                              object
              Priority Class Name:
                Description:  PriorityClassName to be used in the Pod.
                Type:         string
              Resources:
                Description:  Resources describes the compute resource requirements.
                Properties:
                  Limits:
                    Additional Properties:
                      Any Of:
                        Type:                              integer
                        Type:                              string
                      Pattern:                             ^(\+|-)?(([0-9]+(\.[0-9]*)?)|(\.[0-9]+))(([KMGTPE]i)|[numkMGTPE]|([eE](\+|-)?(([0-9]+(\.[0-9]*)?)|(\.[0-9]+))))?$
                      X - Kubernetes - Int - Or - String:  true
                    Description:                           ResourceList is a set of (resource name, quantity) pairs.
                    Type:                                  object
                  Requests:
                    Additional Properties:
                      Any Of:
                        Type:                              integer
                        Type:                              string
                      Pattern:                             ^(\+|-)?(([0-9]+(\.[0-9]*)?)|(\.[0-9]+))(([KMGTPE]i)|[numkMGTPE]|([eE](\+|-)?(([0-9]+(\.[0-9]*)?)|(\.[0-9]+))))?$
                      X - Kubernetes - Int - Or - String:  true
                    Description:                           ResourceList is a set of (resource name, quantity) pairs.
                    Type:                                  object
                Type:                                      object
              Restart Policy:
                Default:      OnFailure
                Description:  RestartPolicy to be added to the Backup Pod.
                Enum:
                  Always
                  OnFailure
                  Never
                Type:  string
              Schedule:
                Description:  Schedule defines when the Backup will be taken.
                Properties:
                  Cron:
                    Description:  Cron is a cron expression that defines the schedule.
                    Type:         string
                  Suspend:
                    Default:      false
                    Description:  Suspend defines whether the schedule is active or not.
                    Type:         boolean
                Required:
                  cron
                Type:  object
              Security Context:
                Description:  SecurityContext holds security configuration that will be applied to a container.
                Properties:
                  Allow Privilege Escalation:
                    Type:  boolean
                  Capabilities:
                    Description:  Adds and removes POSIX capabilities from running containers.
                    Properties:
                      Add:
                        Description:  Added capabilities
                        Items:
                          Description:                 Capability represent POSIX capabilities type
                          Type:                        string
                        Type:                          array
                        X - Kubernetes - List - Type:  atomic
                      Drop:
                        Description:  Removed capabilities
                        Items:
                          Description:                 Capability represent POSIX capabilities type
                          Type:                        string
                        Type:                          array
                        X - Kubernetes - List - Type:  atomic
                    Type:                              object
                  Privileged:
                    Type:  boolean
                  Read Only Root Filesystem:
                    Type:  boolean
                  Run As Group:
                    Format:  int64
                    Type:    integer
                  Run As Non Root:
                    Type:  boolean
                  Run As User:
                    Format:  int64
                    Type:    integer
                Type:        object
              Service Account Name:
                Description:  ServiceAccountName is the name of the ServiceAccount to be used by the Pods.
                Type:         string
              Staging Storage:
                Description:  StagingStorage defines the temporary storage used to keep external backups (i.e. S3) while they are being processed.
It defaults to an emptyDir volume, meaning that the backups will be temporarily stored in the node where the Backup Job is scheduled.
The staging area gets cleaned up after each backup is completed, consider this for sizing it appropriately.
                Properties:
                  Persistent Volume Claim:
                    Description:  PersistentVolumeClaim is a Kubernetes PVC specification.
                    Properties:
                      Access Modes:
                        Items:
                          Type:                        string
                        Type:                          array
                        X - Kubernetes - List - Type:  atomic
                      Resources:
                        Description:  VolumeResourceRequirements describes the storage resource requirements for a volume.
                        Properties:
                          Limits:
                            Additional Properties:
                              Any Of:
                                Type:                              integer
                                Type:                              string
                              Pattern:                             ^(\+|-)?(([0-9]+(\.[0-9]*)?)|(\.[0-9]+))(([KMGTPE]i)|[numkMGTPE]|([eE](\+|-)?(([0-9]+(\.[0-9]*)?)|(\.[0-9]+))))?$
                              X - Kubernetes - Int - Or - String:  true
                            Description:                           Limits describes the maximum amount of compute resources allowed.
More info: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/
                            Type:  object
                          Requests:
                            Additional Properties:
                              Any Of:
                                Type:                              integer
                                Type:                              string
                              Pattern:                             ^(\+|-)?(([0-9]+(\.[0-9]*)?)|(\.[0-9]+))(([KMGTPE]i)|[numkMGTPE]|([eE](\+|-)?(([0-9]+(\.[0-9]*)?)|(\.[0-9]+))))?$
                              X - Kubernetes - Int - Or - String:  true
                            Description:                           Requests describes the minimum amount of compute resources required.
If Requests is omitted for a container, it defaults to Limits if that is explicitly specified,
otherwise to an implementation-defined value. Requests cannot exceed Limits.
More info: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/
                            Type:  object
                        Type:      object
                      Selector:
                        Description:  A label selector is a label query over a set of resources. The result of matchLabels and
matchExpressions are ANDed. An empty label selector matches all objects. A null
label selector matches no objects.
                        Properties:
                          Match Expressions:
                            Description:  matchExpressions is a list of label selector requirements. The requirements are ANDed.
                            Items:
                              Description:  A label selector requirement is a selector that contains values, a key, and an operator that
relates the key and values.
                              Properties:
                                Key:
                                  Description:  key is the label key that the selector applies to.
                                  Type:         string
                                Operator:
                                  Description:  operator represents a key's relationship to a set of values.
Valid operators are In, NotIn, Exists and DoesNotExist.
                                  Type:  string
                                Values:
                                  Description:  values is an array of string values. If the operator is In or NotIn,
the values array must be non-empty. If the operator is Exists or DoesNotExist,
the values array must be empty. This array is replaced during a strategic
merge patch.
                                  Items:
                                    Type:                        string
                                  Type:                          array
                                  X - Kubernetes - List - Type:  atomic
                              Required:
                                key
                                operator
                              Type:                        object
                            Type:                          array
                            X - Kubernetes - List - Type:  atomic
                          Match Labels:
                            Additional Properties:
                              Type:       string
                            Description:  matchLabels is a map of {key,value} pairs. A single {key,value} in the matchLabels
map is equivalent to an element of matchExpressions, whose key field is "key", the
operator is "In", and the values array contains only "value". The requirements are ANDed.
                            Type:                     object
                        Type:                         object
                        X - Kubernetes - Map - Type:  atomic
                      Storage Class Name:
                        Type:  string
                    Type:      object
                  Volume:
                    Description:  Volume is a Kubernetes volume specification.
                    Properties:
                      Csi:
                        Description:  Refer to the Kubernetes docs: https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#csivolumesource-v1-core.
                        Properties:
                          Driver:
                            Type:  string
                          Fs Type:
                            Type:  string
                          Node Publish Secret Ref:
                            Description:  Refer to the Kubernetes docs: https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#localobjectreference-v1-core.
                            Properties:
                              Name:
                                Default:  
                                Type:     string
                            Type:         object
                          Read Only:
                            Type:  boolean
                          Volume Attributes:
                            Additional Properties:
                              Type:  string
                            Type:    object
                        Required:
                          driver
                        Type:  object
                      Empty Dir:
                        Description:  Refer to the Kubernetes docs: https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#emptydirvolumesource-v1-core.
                        Properties:
                          Medium:
                            Description:  StorageMedium defines ways that storage can be allocated to a volume.
                            Type:         string
                          Size Limit:
                            Any Of:
                              Type:                              integer
                              Type:                              string
                            Pattern:                             ^(\+|-)?(([0-9]+(\.[0-9]*)?)|(\.[0-9]+))(([KMGTPE]i)|[numkMGTPE]|([eE](\+|-)?(([0-9]+(\.[0-9]*)?)|(\.[0-9]+))))?$
                            X - Kubernetes - Int - Or - String:  true
                        Type:                                    object
                      Host Path:
                        Description:  Refer to the Kubernetes docs: https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#hostpathvolumesource-v1-core
                        Properties:
                          Path:
                            Type:  string
                          Type:
                            Type:  string
                        Required:
                          path
                        Type:  object
                      Nfs:
                        Description:  Refer to the Kubernetes docs: https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#nfsvolumesource-v1-core.
                        Properties:
                          Path:
                            Type:  string
                          Read Only:
                            Type:  boolean
                          Server:
                            Type:  string
                        Required:
                          path
                          server
                        Type:  object
                      Persistent Volume Claim:
                        Description:  Refer to the Kubernetes docs: https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#persistentvolumeclaimvolumesource-v1-core.
                        Properties:
                          Claim Name:
                            Type:  string
                          Read Only:
                            Type:  boolean
                        Required:
                          claimName
                        Type:  object
                    Type:      object
                Type:          object
              Storage:
                Description:  Storage defines the final storage for backups.
                Properties:
                  Persistent Volume Claim:
                    Description:  PersistentVolumeClaim is a Kubernetes PVC specification.
                    Properties:
                      Access Modes:
                        Items:
                          Type:                        string
                        Type:                          array
                        X - Kubernetes - List - Type:  atomic
                      Resources:
                        Description:  VolumeResourceRequirements describes the storage resource requirements for a volume.
                        Properties:
                          Limits:
                            Additional Properties:
                              Any Of:
                                Type:                              integer
                                Type:                              string
                              Pattern:                             ^(\+|-)?(([0-9]+(\.[0-9]*)?)|(\.[0-9]+))(([KMGTPE]i)|[numkMGTPE]|([eE](\+|-)?(([0-9]+(\.[0-9]*)?)|(\.[0-9]+))))?$
                              X - Kubernetes - Int - Or - String:  true
                            Description:                           Limits describes the maximum amount of compute resources allowed.
More info: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/
                            Type:  object
                          Requests:
                            Additional Properties:
                              Any Of:
                                Type:                              integer
                                Type:                              string
                              Pattern:                             ^(\+|-)?(([0-9]+(\.[0-9]*)?)|(\.[0-9]+))(([KMGTPE]i)|[numkMGTPE]|([eE](\+|-)?(([0-9]+(\.[0-9]*)?)|(\.[0-9]+))))?$
                              X - Kubernetes - Int - Or - String:  true
                            Description:                           Requests describes the minimum amount of compute resources required.
If Requests is omitted for a container, it defaults to Limits if that is explicitly specified,
otherwise to an implementation-defined value. Requests cannot exceed Limits.
More info: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/
                            Type:  object
                        Type:      object
                      Selector:
                        Description:  A label selector is a label query over a set of resources. The result of matchLabels and
matchExpressions are ANDed. An empty label selector matches all objects. A null
label selector matches no objects.
                        Properties:
                          Match Expressions:
                            Description:  matchExpressions is a list of label selector requirements. The requirements are ANDed.
                            Items:
                              Description:  A label selector requirement is a selector that contains values, a key, and an operator that
relates the key and values.
                              Properties:
                                Key:
                                  Description:  key is the label key that the selector applies to.
                                  Type:         string
                                Operator:
                                  Description:  operator represents a key's relationship to a set of values.
Valid operators are In, NotIn, Exists and DoesNotExist.
                                  Type:  string
                                Values:
                                  Description:  values is an array of string values. If the operator is In or NotIn,
the values array must be non-empty. If the operator is Exists or DoesNotExist,
the values array must be empty. This array is replaced during a strategic
merge patch.
                                  Items:
                                    Type:                        string
                                  Type:                          array
                                  X - Kubernetes - List - Type:  atomic
                              Required:
                                key
                                operator
                              Type:                        object
                            Type:                          array
                            X - Kubernetes - List - Type:  atomic
                          Match Labels:
                            Additional Properties:
                              Type:       string
                            Description:  matchLabels is a map of {key,value} pairs. A single {key,value} in the matchLabels
map is equivalent to an element of matchExpressions, whose key field is "key", the
operator is "In", and the values array contains only "value". The requirements are ANDed.
                            Type:                     object
                        Type:                         object
                        X - Kubernetes - Map - Type:  atomic
                      Storage Class Name:
                        Type:  string
                    Type:      object
                  s3:
                    Description:  S3 defines the configuration to store backups in a S3 compatible storage.
                    Properties:
                      Access Key Id Secret Key Ref:
                        Description:  AccessKeyIdSecretKeyRef is a reference to a Secret key containing the S3 access key id.
                        Properties:
                          Key:
                            Type:  string
                          Name:
                            Default:  
                            Type:     string
                        Required:
                          key
                        Type:                         object
                        X - Kubernetes - Map - Type:  atomic
                      Bucket:
                        Description:  Bucket is the name Name of the bucket to store backups.
                        Type:         string
                      Endpoint:
                        Description:  Endpoint is the S3 API endpoint without scheme.
                        Type:         string
                      Prefix:
                        Description:  Prefix indicates a folder/subfolder in the bucket. For example: mariadb/ or mariadb/backups. A trailing slash '/' is added if not provided.
                        Type:         string
                      Region:
                        Description:  Region is the S3 region name to use.
                        Type:         string
                      Secret Access Key Secret Key Ref:
                        Description:  AccessKeyIdSecretKeyRef is a reference to a Secret key containing the S3 secret key.
                        Properties:
                          Key:
                            Type:  string
                          Name:
                            Default:  
                            Type:     string
                        Required:
                          key
                        Type:                         object
                        X - Kubernetes - Map - Type:  atomic
                      Session Token Secret Key Ref:
                        Description:  SessionTokenSecretKeyRef is a reference to a Secret key containing the S3 session token.
                        Properties:
                          Key:
                            Type:  string
                          Name:
                            Default:  
                            Type:     string
                        Required:
                          key
                        Type:                         object
                        X - Kubernetes - Map - Type:  atomic
                      Tls:
                        Description:  TLS provides the configuration required to establish TLS connections with S3.
                        Properties:
                          Ca Secret Key Ref:
                            Description:  CASecretKeyRef is a reference to a Secret key containing a CA bundle in PEM format used to establish TLS connections with S3.
By default, the system trust chain will be used, but you can use this field to add more CAs to the bundle.
                            Properties:
                              Key:
                                Type:  string
                              Name:
                                Default:  
                                Type:     string
                            Required:
                              key
                            Type:                         object
                            X - Kubernetes - Map - Type:  atomic
                          Enabled:
                            Description:  Enabled is a flag to enable TLS.
                            Type:         boolean
                        Type:             object
                    Required:
                      bucket
                      endpoint
                    Type:  object
                  Volume:
                    Description:  Volume is a Kubernetes volume specification.
                    Properties:
                      Csi:
                        Description:  Refer to the Kubernetes docs: https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#csivolumesource-v1-core.
                        Properties:
                          Driver:
                            Type:  string
                          Fs Type:
                            Type:  string
                          Node Publish Secret Ref:
                            Description:  Refer to the Kubernetes docs: https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#localobjectreference-v1-core.
                            Properties:
                              Name:
                                Default:  
                                Type:     string
                            Type:         object
                          Read Only:
                            Type:  boolean
                          Volume Attributes:
                            Additional Properties:
                              Type:  string
                            Type:    object
                        Required:
                          driver
                        Type:  object
                      Empty Dir:
                        Description:  Refer to the Kubernetes docs: https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#emptydirvolumesource-v1-core.
                        Properties:
                          Medium:
                            Description:  StorageMedium defines ways that storage can be allocated to a volume.
                            Type:         string
                          Size Limit:
                            Any Of:
                              Type:                              integer
                              Type:                              string
                            Pattern:                             ^(\+|-)?(([0-9]+(\.[0-9]*)?)|(\.[0-9]+))(([KMGTPE]i)|[numkMGTPE]|([eE](\+|-)?(([0-9]+(\.[0-9]*)?)|(\.[0-9]+))))?$
                            X - Kubernetes - Int - Or - String:  true
                        Type:                                    object
                      Host Path:
                        Description:  Refer to the Kubernetes docs: https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#hostpathvolumesource-v1-core
                        Properties:
                          Path:
                            Type:  string
                          Type:
                            Type:  string
                        Required:
                          path
                        Type:  object
                      Nfs:
                        Description:  Refer to the Kubernetes docs: https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#nfsvolumesource-v1-core.
                        Properties:
                          Path:
                            Type:  string
                          Read Only:
                            Type:  boolean
                          Server:
                            Type:  string
                        Required:
                          path
                          server
                        Type:  object
                      Persistent Volume Claim:
                        Description:  Refer to the Kubernetes docs: https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#persistentvolumeclaimvolumesource-v1-core.
                        Properties:
                          Claim Name:
                            Type:  string
                          Read Only:
                            Type:  boolean
                        Required:
                          claimName
                        Type:  object
                    Type:      object
                Type:          object
              Successful Jobs History Limit:
                Description:  SuccessfulJobsHistoryLimit defines the maximum number of successful Jobs to be displayed.
                Format:       int32
                Minimum:      0
                Type:         integer
              Time Zone:
                Description:  TimeZone defines the timezone associated with the cron expression.
                Type:         string
              Tolerations:
                Description:  Tolerations to be used in the Pod.
                Items:
                  Description:  The pod this Toleration is attached to tolerates any taint that matches
the triple <key,value,effect> using the matching operator <operator>.
                  Properties:
                    Effect:
                      Description:  Effect indicates the taint effect to match. Empty means match all taint effects.
When specified, allowed values are NoSchedule, PreferNoSchedule and NoExecute.
                      Type:  string
                    Key:
                      Description:  Key is the taint key that the toleration applies to. Empty means match all taint keys.
If the key is empty, operator must be Exists; this combination means to match all values and all keys.
                      Type:  string
                    Operator:
                      Description:  Operator represents a key's relationship to the value.
Valid operators are Exists and Equal. Defaults to Equal.
Exists is equivalent to wildcard for value, so that a pod can
tolerate all taints of a particular category.
                      Type:  string
                    Toleration Seconds:
                      Description:  TolerationSeconds represents the period of time the toleration (which must be
of effect NoExecute, otherwise this field is ignored) tolerates the taint. By default,
it is not set, which means tolerate the taint forever (do not evict). Zero and
negative values will be treated as 0 (evict immediately) by the system.
                      Format:  int64
                      Type:    integer
                    Value:
                      Description:  Value is the taint value the toleration matches to.
If the operator is Exists, the value should be empty, otherwise just a regular string.
                      Type:  string
                  Type:      object
                Type:        array
            Required:
              mariaDbRef
              storage
            Type:  object
          Status:
            Description:  BackupStatus defines the observed state of Backup
            Properties:
              Conditions:
                Description:  Conditions for the Backup object.
                Items:
                  Description:  Condition contains details for one aspect of the current state of this API Resource.
                  Properties:
                    Last Transition Time:
                      Description:  lastTransitionTime is the last time the condition transitioned from one status to another.
This should be when the underlying condition changed.  If that is not known, then using the time when the API field changed is acceptable.
                      Format:  date-time
                      Type:    string
                    Message:
                      Description:  message is a human readable message indicating details about the transition.
This may be an empty string.
                      Max Length:  32768
                      Type:        string
                    Observed Generation:
                      Description:  observedGeneration represents the .metadata.generation that the condition was set based upon.
For instance, if .metadata.generation is currently 12, but the .status.conditions[x].observedGeneration is 9, the condition is out of date
with respect to the current state of the instance.
                      Format:   int64
                      Minimum:  0
                      Type:     integer
                    Reason:
                      Description:  reason contains a programmatic identifier indicating the reason for the condition's last transition.
Producers of specific condition types may define expected values and meanings for this field,
and whether the values are considered a guaranteed API.
The value should be a CamelCase string.
This field may not be empty.
                      Max Length:  1024
                      Min Length:  1
                      Pattern:     ^[A-Za-z]([A-Za-z0-9_,:]*[A-Za-z0-9_])?$
                      Type:        string
                    Status:
                      Description:  status of the condition, one of True, False, Unknown.
                      Enum:
                        True
                        False
                        Unknown
                      Type:  string
                    Type:
                      Description:  type of condition in CamelCase or in foo.example.com/CamelCase.
                      Max Length:   316
                      Pattern:      ^([a-z0-9]([-a-z0-9]*[a-z0-9])?(\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*/)?(([A-Za-z0-9][-A-Za-z0-9_.]*)?[A-Za-z0-9])$
                      Type:         string
                  Required:
                    lastTransitionTime
                    message
                    reason
                    status
                    type
                  Type:  object
                Type:    array
            Type:        object
        Type:            object
    Served:              true
    Storage:             true
    Subresources:
      Status:
Status:
  Accepted Names:
    Kind:       Backup
    List Kind:  BackupList
    Plural:     backups
    Short Names:
      bmdb
    Singular:  backup
  Conditions:
    Last Transition Time:  2025-09-08T16:23:35Z
    Message:               no conflicts found
    Reason:                NoConflicts
    Status:                True
    Type:                  NamesAccepted
    Last Transition Time:  2025-09-08T16:23:35Z
    Message:               the initial names have been accepted
    Reason:                InitialNamesAccepted
    Status:                True
    Type:                  Established
  Stored Versions:
    v1alpha1
Events:  <none>
