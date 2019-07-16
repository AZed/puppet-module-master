class master::dev::graph {
  package { ["graphviz","graphviz-doc"]: ensure => latest }
}
