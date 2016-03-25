
function clearTable(){
  document.getElementById("results").innerHTML="";
}

function clearMetrics(){
  //clean metrics
  var selectbox = document.getElementById("metrics");
  for(i=selectbox.options.length-1;i>=0;i--)
  {
      selectbox.remove(i);
  }
}

function onLoad(){
  clearMetrics();
  clearTable();
  window.location.href = 'skp:on_load@message';
}

function changeMetric(){
  clearTable();
  window.location.href = 'skp:select_metric@message';
}

onLoad();
