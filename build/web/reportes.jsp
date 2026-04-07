<%@ page isELIgnored="true"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    if (session.getAttribute("username") == null) { response.sendRedirect("index.jsp"); return; }
    String username = (String) session.getAttribute("username");
%>
<!DOCTYPE html><html lang="es"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>Reportes - HiperInventory</title>
<link rel="stylesheet" href="css/styles.css">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<style>
.report-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(280px,1fr));gap:20px;margin-bottom:30px;}
.report-card{background:#fff;border-radius:12px;padding:24px;box-shadow:0 2px 8px rgba(0,0,0,.08);border-top:4px solid #667eea;}
.report-card h4{margin:0 0 8px;font-size:16px;color:#333;}.report-card p{margin:0 0 16px;font-size:13px;color:#888;}
.btn-group{display:flex;gap:8px;flex-wrap:wrap;}
.btn-pdf{background:#f44336;color:#fff;border:none;border-radius:6px;padding:8px 14px;cursor:pointer;font-size:13px;}
.btn-excel{background:#4caf50;color:#fff;border:none;border-radius:6px;padding:8px 14px;cursor:pointer;font-size:13px;}
.btn-csv{background:#2196f3;color:#fff;border:none;border-radius:6px;padding:8px 14px;cursor:pointer;font-size:13px;}
.filters-bar{background:#fff;border-radius:12px;padding:20px;box-shadow:0 2px 8px rgba(0,0,0,.08);margin-bottom:24px;display:flex;gap:16px;flex-wrap:wrap;align-items:flex-end;}
.filter-group{display:flex;flex-direction:column;gap:4px;min-width:160px;}
.filter-group label{font-size:12px;color:#888;font-weight:600;text-transform:uppercase;}
.filter-group select,.filter-group input{padding:8px 12px;border:1px solid #e0e0e0;border-radius:6px;font-size:13px;}
.preview-table{width:100%;border-collapse:collapse;font-size:13px;}
.preview-table th{background:#f5f5f5;padding:10px 12px;text-align:left;font-weight:600;color:#555;border-bottom:2px solid #e0e0e0;}
.preview-table td{padding:10px 12px;border-bottom:1px solid #f0f0f0;}
.stat-summary{display:flex;gap:16px;flex-wrap:wrap;margin-bottom:24px;}
.stat-pill{background:#fff;border-radius:8px;padding:12px 20px;box-shadow:0 2px 8px rgba(0,0,0,.06);font-size:13px;color:#555;display:flex;align-items:center;gap:8px;}
.stat-pill strong{font-size:20px;color:#333;}
</style></head><body>
<aside class="sidebar"><div class="sidebar-header"><h1><i class="fas fa-cube"></i> HiperInventory</h1></div>
<nav><ul class="sidebar-nav">
<li><a href="inicio.jsp"><i class="fas fa-chart-line"></i> Dashboard</a></li>
<li><a href="activos.jsp"><i class="fas fa-box"></i> Activos</a></li>
<li><a href="categorias.jsp"><i class="fas fa-tags"></i> Categorias</a></li>
<li><a href="ubicaciones.jsp"><i class="fas fa-map-marker-alt"></i> Ubicaciones</a></li>
<li><a href="usuarios.jsp"><i class="fas fa-users"></i> Usuarios</a></li>
<li><a href="reportes.jsp" class="active"><i class="fas fa-file-pdf"></i> Reportes</a></li>
<li><hr style="border:none;border-top:1px solid rgba(255,255,255,0.1);margin:15px 0;"></li>
<li><a href="logout.jsp"><i class="fas fa-sign-out-alt"></i> Cerrar Sesion</a></li>
</ul></nav></aside>
<div class="main-layout">
<header class="topbar">
<div style="display:flex;align-items:center;gap:15px;"><button class="hamburger"><i class="fas fa-bars"></i></button><h2 class="topbar-title">Reportes</h2></div>
<div class="topbar-right"><div class="user-menu"><div class="user-avatar"><%= Character.toUpperCase(username.charAt(0)) %></div><span><%= username %></span></div></div>
</header>
<main class="main-content">
<div class="stat-summary">
<div class="stat-pill"><i class="fas fa-boxes" style="color:#667eea;"></i> Total: <strong id="sTotal">-</strong></div>
<div class="stat-pill"><i class="fas fa-check-circle" style="color:#4caf50;"></i> Operativos: <strong id="sOp">-</strong></div>
<div class="stat-pill"><i class="fas fa-tools" style="color:#ff9800;"></i> Reparacion: <strong id="sRep">-</strong></div>
<div class="stat-pill"><i class="fas fa-ban" style="color:#f44336;"></i> Baja: <strong id="sBaja">-</strong></div>
</div>
<div class="report-grid">
<div class="report-card"><h4><i class="fas fa-boxes" style="color:#667eea;margin-right:8px;"></i>Inventario Completo</h4><p>Todos los activos.</p><div class="btn-group"><button class="btn-pdf" onclick="exportReport('all','pdf')"><i class="fas fa-file-pdf"></i> PDF</button><button class="btn-excel" onclick="exportReport('all','excel')"><i class="fas fa-file-excel"></i> Excel</button><button class="btn-csv" onclick="exportReport('all','csv')"><i class="fas fa-file-csv"></i> CSV</button></div></div>
<div class="report-card" style="border-top-color:#4caf50;"><h4><i class="fas fa-check-circle" style="color:#4caf50;margin-right:8px;"></i>Activos Operativos</h4><p>Solo activos operativos.</p><div class="btn-group"><button class="btn-pdf" onclick="exportReport('operativo','pdf')"><i class="fas fa-file-pdf"></i> PDF</button><button class="btn-excel" onclick="exportReport('operativo','excel')"><i class="fas fa-file-excel"></i> Excel</button><button class="btn-csv" onclick="exportReport('operativo','csv')"><i class="fas fa-file-csv"></i> CSV</button></div></div>
<div class="report-card" style="border-top-color:#ff9800;"><h4><i class="fas fa-tools" style="color:#ff9800;margin-right:8px;"></i>En Reparacion</h4><p>Activos en mantenimiento.</p><div class="btn-group"><button class="btn-pdf" onclick="exportReport('reparacion','pdf')"><i class="fas fa-file-pdf"></i> PDF</button><button class="btn-excel" onclick="exportReport('reparacion','excel')"><i class="fas fa-file-excel"></i> Excel</button><button class="btn-csv" onclick="exportReport('reparacion','csv')"><i class="fas fa-file-csv"></i> CSV</button></div></div>
<div class="report-card" style="border-top-color:#f44336;"><h4><i class="fas fa-exclamation-triangle" style="color:#f44336;margin-right:8px;"></i>Stock Bajo</h4><p>Activos bajo el minimo.</p><div class="btn-group"><button class="btn-pdf" onclick="exportReport('low-stock','pdf')"><i class="fas fa-file-pdf"></i> PDF</button><button class="btn-excel" onclick="exportReport('low-stock','excel')"><i class="fas fa-file-excel"></i> Excel</button><button class="btn-csv" onclick="exportReport('low-stock','csv')"><i class="fas fa-file-csv"></i> CSV</button></div></div>
</div>
<div class="card">
<h3 class="card-title"><i class="fas fa-filter"></i> Vista Previa con Filtros</h3>
<div class="filters-bar">
<div class="filter-group"><label>Categoria</label><select id="fCat" onchange="loadPreview()"><option value="">Todas</option></select></div>
<div class="filter-group"><label>Estado</label><select id="fEst" onchange="loadPreview()"><option value="">Todos</option><option>Operativo</option><option>En reparacion</option><option>Baja</option><option>En prestamo</option></select></div>
<div class="filter-group"><label>Ubicacion</label><select id="fUb" onchange="loadPreview()"><option value="">Todas</option></select></div>
<div class="filter-group"><label>Buscar</label><input type="text" id="fQ" placeholder="Nombre o codigo..." oninput="loadPreview()"></div>
<div style="display:flex;gap:8px;align-items:flex-end;">
<button class="btn-pdf" onclick="exportFiltered('pdf')"><i class="fas fa-file-pdf"></i> PDF</button>
<button class="btn-excel" onclick="exportFiltered('excel')"><i class="fas fa-file-excel"></i> Excel</button>
<button class="btn-csv" onclick="exportFiltered('csv')"><i class="fas fa-file-csv"></i> CSV</button>
</div></div>
<div style="overflow-x:auto;"><table class="preview-table">
<thead><tr><th>Codigo</th><th>Nombre</th><th>Categoria</th><th>Estado</th><th>Ubicacion</th><th>Cantidad</th><th>Valor</th></tr></thead>
<tbody id="prevBody"><tr><td colspan="7" style="text-align:center;padding:30px;color:#999;"><i class="fas fa-spinner fa-spin"></i></td></tr></tbody>
</table></div>
<div id="prevCount" style="padding:10px 0;font-size:13px;color:#888;"></div>
</div></main></div>
<script src="js/app.js"></script>
<script>
var allA=[],cu='<%= username %>';
var sc={'Operativo':'#4caf50','En reparacion':'#ff9800','En reparacion':'#ff9800','Baja':'#f44336','En prestamo':'#2196f3'};
function init(){
fetch('api/assets/stats').then(function(r){return r.json();}).then(function(j){var s=j.data||{};document.getElementById('sTotal').textContent=s.total||0;document.getElementById('sOp').textContent=s.operativo||0;document.getElementById('sRep').textContent=s.reparacion||0;document.getElementById('sBaja').textContent=s.baja||0;}).catch(function(){});
Promise.all([fetch('api/categorias'),fetch('api/ubicaciones')]).then(function(rs){return Promise.all(rs.map(function(r){return r.json();}));}).then(function(d){
var fc=document.getElementById('fCat'),fu=document.getElementById('fUb');
(d[0].data||[]).forEach(function(c){var o=document.createElement('option');o.value=c.nombre;o.textContent=c.nombre;fc.appendChild(o);});
(d[1].data||[]).forEach(function(u){var o=document.createElement('option');o.value=u.nombre;o.textContent=u.nombre;fu.appendChild(o);});
}).catch(function(){});
fetch('api/assets').then(function(r){return r.json();}).then(function(j){allA=j.data||[];renderPrev(allA);}).catch(function(){});
}
function getFilt(){var cat=document.getElementById('fCat').value,est=document.getElementById('fEst').value,ub=document.getElementById('fUb').value,q=document.getElementById('fQ').value.toLowerCase();return allA.filter(function(a){return(!cat||a.categoria==cat)&&(!est||a.estado==est)&&(!ub||a.ubicacion==ub)&&(!q||a.nombre.toLowerCase().indexOf(q)>=0||(a.codigo||'').toLowerCase().indexOf(q)>=0);});}
function loadPreview(){renderPrev(getFilt());}
function renderPrev(data){document.getElementById('prevCount').textContent='Mostrando '+data.length+' activo(s)';var t=document.getElementById('prevBody');if(!data.length){t.innerHTML='<tr><td colspan="7" style="text-align:center;padding:20px;color:#999;">Sin resultados</td></tr>';return;}var h='';var s=data.slice(0,50);for(var i=0;i<s.length;i++){var a=s[i];var c=sc[a.estado]||'#666';h+='<tr><td><code>'+(a.codigo||'-')+'</code></td><td>'+a.nombre+'</td><td>'+(a.categoria||'-')+'</td><td style="color:'+c+';font-weight:600;">'+(a.estado||'-')+'</td><td>'+(a.ubicacion||'-')+'</td><td>'+(a.cantidad||0)+'</td><td>$'+((a.valor||0).toLocaleString('es'))+'</td></tr>';}if(data.length>50)h+='<tr><td colspan="7" style="text-align:center;color:#888;font-style:italic;">... y '+(data.length-50)+' mas</td></tr>';t.innerHTML=h;}
function exportReport(type,format){var data=allA;if(type=='operativo')data=allA.filter(function(a){return a.estado=='Operativo';});else if(type=='reparacion')data=allA.filter(function(a){return a.estado=='En reparacion'||a.estado=='En reparacion';});else if(type=='low-stock'){fetch('api/assets/low-stock').then(function(r){return r.json();}).then(function(j){doExport(j.data||[],'Stock Bajo',format);});return;}var t={all:'Inventario Completo',operativo:'Activos Operativos',reparacion:'En Reparacion'};doExport(data,t[type]||'Reporte',format);}
function exportFiltered(format){doExport(getFilt(),'Reporte Filtrado',format);}
function doExport(data,title,format){if(format=='csv')exportCSV(data,title);else if(format=='excel')exportExcel(data,title);else exportPDF(data,title);}
function exportCSV(data,title){var h=['Codigo','Nombre','Categoria','Estado','Ubicacion','Cantidad','Valor'];var rows=data.map(function(a){return[a.codigo||'',a.nombre||'',a.categoria||'',a.estado||'',a.ubicacion||'',a.cantidad||0,a.valor||0].map(function(v){return'"'+String(v).replace(/"/g,'""')+'"';}).join(',');});var csv='\uFEFF'+[h.join(',')].concat(rows).join('\n');dl(new Blob([csv],{type:'text/csv;charset=utf-8;'}),title+'.csv');}
function exportExcel(data,title){var h=['Codigo','Nombre','Categoria','Estado','Ubicacion','Cantidad','Valor'];var html='<html xmlns:o="urn:schemas-microsoft-com:office:office"><head><meta charset="UTF-8"><style>th{background:#667eea;color:#fff;padding:6px;}td{padding:5px;border:1px solid #ddd;}</style></head><body><h2>'+title+'</h2><p>'+new Date().toLocaleString('es')+' | '+cu+'</p><table border="1"><thead><tr>'+h.map(function(x){return'<th>'+x+'</th>';}).join('')+'</tr></thead><tbody>';data.forEach(function(a){html+='<tr><td>'+(a.codigo||'')+'</td><td>'+(a.nombre||'')+'</td><td>'+(a.categoria||'')+'</td><td>'+(a.estado||'')+'</td><td>'+(a.ubicacion||'')+'</td><td>'+(a.cantidad||0)+'</td><td>'+(a.valor||0)+'</td></tr>';});html+='</tbody></table></body></html>';dl(new Blob(['\uFEFF'+html],{type:'application/vnd.ms-excel;charset=utf-8;'}),title+'.xls');}
function exportPDF(data,title){var win=window.open('','_blank');var rows='';data.forEach(function(a){var c=sc[a.estado]||'#333';rows+='<tr><td>'+(a.codigo||'-')+'</td><td>'+(a.nombre||'-')+'</td><td>'+(a.categoria||'-')+'</td><td style="color:'+c+';font-weight:600;">'+(a.estado||'-')+'</td><td>'+(a.ubicacion||'-')+'</td><td>'+(a.cantidad||0)+'</td><td>$'+((a.valor||0).toLocaleString('es'))+'</td></tr>';});win.document.write('<!DOCTYPE html><html><head><meta charset="UTF-8"><title>'+title+'</title><style>body{font-family:Arial,sans-serif;margin:30px;}h1{color:#667eea;border-bottom:3px solid #667eea;padding-bottom:10px;}.meta{color:#888;font-size:13px;margin-bottom:20px;}table{width:100%;border-collapse:collapse;font-size:12px;}th{background:#667eea;color:#fff;padding:8px 10px;text-align:left;}td{padding:7px 10px;border-bottom:1px solid #eee;}tr:nth-child(even) td{background:#f9f9f9;}@media print{button{display:none;}}</style></head><body><h1>'+title+'</h1><div class="meta">'+new Date().toLocaleString('es')+' | Total: '+data.length+' | '+cu+'</div><button onclick="window.print()" style="background:#667eea;color:#fff;border:none;padding:8px 18px;border-radius:6px;cursor:pointer;margin-bottom:16px;">Imprimir / PDF</button><table><thead><tr><th>Codigo</th><th>Nombre</th><th>Categoria</th><th>Estado</th><th>Ubicacion</th><th>Cantidad</th><th>Valor</th></tr></thead><tbody>'+rows+'</tbody></table></body></html>');win.document.close();}
function dl(blob,fn){var a=document.createElement('a');a.href=URL.createObjectURL(blob);a.download=fn;a.click();setTimeout(function(){URL.revokeObjectURL(a.href);},1000);}
document.addEventListener('DOMContentLoaded',init);
</script></body></html>