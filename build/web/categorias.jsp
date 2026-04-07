<%@ page isELIgnored="true"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    if (session.getAttribute("username") == null) { response.sendRedirect("index.jsp"); return; }
    String username = (String) session.getAttribute("username");
    String userRole = (String) session.getAttribute("userRole");
    boolean isEditor = "ADMIN".equals(userRole) || "EDITOR".equals(userRole);
%>
<!DOCTYPE html><html lang="es"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Categorias - HiperInventory</title>
<link rel="stylesheet" href="css/styles.css">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<style>.badge-count{background:#667eea;color:#fff;border-radius:12px;padding:2px 10px;font-size:12px;}.btn-small{padding:4px 10px;font-size:12px;}.btn-danger{background:#f44336;color:#fff;border:none;border-radius:6px;cursor:pointer;}.alert{padding:12px 16px;border-radius:8px;margin-bottom:12px;display:flex;align-items:center;gap:8px;}.alert-success{background:#e8f5e9;color:#2e7d32;border-left:4px solid #4caf50;}.alert-error{background:#ffebee;color:#c62828;border-left:4px solid #f44336;}</style>
</head><body>
<aside class="sidebar"><div class="sidebar-header"><h1><i class="fas fa-cube"></i> HiperInventory</h1></div>
<nav><ul class="sidebar-nav">
<li><a href="inicio.jsp"><i class="fas fa-chart-line"></i> Dashboard</a></li>
<li><a href="activos.jsp"><i class="fas fa-box"></i> Activos</a></li>
<li><a href="categorias.jsp" class="active"><i class="fas fa-tags"></i> Categorias</a></li>
<li><a href="ubicaciones.jsp"><i class="fas fa-map-marker-alt"></i> Ubicaciones</a></li>
<li><a href="usuarios.jsp"><i class="fas fa-users"></i> Usuarios</a></li>
<li><a href="reportes.jsp"><i class="fas fa-file-pdf"></i> Reportes</a></li>
<li><hr style="border:none;border-top:1px solid rgba(255,255,255,0.1);margin:15px 0;"></li>
<li><a href="logout.jsp"><i class="fas fa-sign-out-alt"></i> Cerrar Sesion</a></li>
</ul></nav></aside>
<div class="main-layout">
<header class="topbar">
<div style="display:flex;align-items:center;gap:15px;"><button class="hamburger"><i class="fas fa-bars"></i></button><h2 class="topbar-title">Categorias</h2></div>
<div class="topbar-right"><div class="user-menu"><div class="user-avatar"><%= Character.toUpperCase(username.charAt(0)) %></div><span><%= username %></span></div></div>
</header>
<main class="main-content">
<div id="alert-container"></div>
<div class="table-container">
<div class="table-controls">
<div class="search-box"><i class="fas fa-search"></i><input type="text" id="searchInput" placeholder="Buscar..." oninput="filterTable()"></div>
<% if (isEditor) { %><button class="btn btn-primary" onclick="openModal()"><i class="fas fa-plus"></i> Nueva Categoria</button><% } %>
</div>
<table><thead><tr><th>#</th><th>Icono</th><th>Nombre</th><th>Descripcion</th><th>Activos</th><th>Fecha</th><% if (isEditor) { %><th>Acciones</th><% } %></tr></thead>
<tbody id="tableBody"><tr><td colspan="7" style="text-align:center;padding:40px;color:#999;"><i class="fas fa-spinner fa-spin"></i> Cargando...</td></tr></tbody>
</table></div></main></div>
<div class="modal" id="catModal"><div class="modal-content"><div class="modal-header"><h3 class="modal-title" id="modalTitle">Nueva Categoria</h3><button class="modal-close" onclick="closeModal()">&times;</button></div>
<div class="modal-body"><input type="hidden" id="catId">
<div class="form-group"><label>Nombre *</label><input type="text" id="catNombre" placeholder="Ej: Computadoras"></div>
<div class="form-group"><label>Icono (FontAwesome)</label><div style="display:flex;gap:8px;align-items:center;"><input type="text" id="catIcono" placeholder="fas fa-laptop" oninput="prevIcon()"><span id="iconPrev" style="font-size:22px;width:30px;"></span></div></div>
<div class="form-group"><label>Descripcion</label><textarea id="catDesc" rows="2" placeholder="Opcional..."></textarea></div>
</div>
<div class="modal-footer"><button class="btn btn-secondary" onclick="closeModal()">Cancelar</button><button class="btn btn-primary" onclick="saveCategoria()"><i class="fas fa-save"></i> Guardar</button></div>
</div></div>
<div class="modal" id="delModal"><div class="modal-content" style="max-width:380px;"><div class="modal-header"><h3 class="modal-title">Eliminar</h3><button class="modal-close" onclick="document.getElementById('delModal').classList.remove('show')">&times;</button></div>
<div class="modal-body"><p>Eliminar categoria <strong id="delNombre"></strong>?</p></div>
<div class="modal-footer"><button class="btn btn-secondary" onclick="document.getElementById('delModal').classList.remove('show')">Cancelar</button><button class="btn btn-danger" onclick="confirmDelete()"><i class="fas fa-trash"></i> Eliminar</button></div>
</div></div>
<script src="js/app.js"></script>
<script>
var IS_EDITOR=<%= isEditor %>,cats=[],delId=null;
function load(){fetch('api/categorias').then(function(r){return r.json();}).then(function(j){cats=j.data||[];render(cats);}).catch(function(e){alert('Error: '+e.message);});}
function render(data){var t=document.getElementById('tableBody');if(!data.length){t.innerHTML='<tr><td colspan="7" style="text-align:center;padding:40px;color:#999;">No hay categorias</td></tr>';return;}var h='';for(var i=0;i<data.length;i++){var c=data[i];var ic=c.icono?'<i class="'+c.icono+'" style="font-size:18px;color:#667eea;"></i>':'<i class="fas fa-tag" style="color:#ccc;"></i>';var dt=c.fechaCreacion?new Date(c.fechaCreacion).toLocaleDateString('es'):'—';var ac=IS_EDITOR?'<td><button class="btn btn-secondary btn-small" onclick="edit('+c.id+')"><i class="fas fa-edit"></i></button> <button class="btn btn-danger btn-small" onclick="askDel('+c.id+',\''+c.nombre.replace(/\'/g,"\\'")+'\')"><i class="fas fa-trash"></i></button></td>':'';h+='<tr><td>'+(i+1)+'</td><td style="text-align:center;">'+ic+'</td><td><strong>'+c.nombre+'</strong></td><td>'+(c.descripcion||'<span style="color:#ccc">—</span>')+'</td><td><span class="badge-count">'+(c.totalActivos||0)+'</span></td><td>'+dt+'</td>'+ac+'</tr>';}t.innerHTML=h;}
function filterTable(){var q=document.getElementById('searchInput').value.toLowerCase();render(cats.filter(function(c){return c.nombre.toLowerCase().indexOf(q)>=0||(c.descripcion||'').toLowerCase().indexOf(q)>=0;}));}
function prevIcon(){document.getElementById('iconPrev').className=document.getElementById('catIcono').value.trim();}
function openModal(){document.getElementById('catId').value='';document.getElementById('catNombre').value='';document.getElementById('catIcono').value='';document.getElementById('catDesc').value='';document.getElementById('iconPrev').className='';document.getElementById('modalTitle').textContent='Nueva Categoria';document.getElementById('catModal').classList.add('show');}
function edit(id){var c=null;for(var i=0;i<cats.length;i++){if(cats[i].id===id){c=cats[i];break;}}if(!c)return;document.getElementById('catId').value=c.id;document.getElementById('catNombre').value=c.nombre;document.getElementById('catIcono').value=c.icono||'';document.getElementById('catDesc').value=c.descripcion||'';document.getElementById('iconPrev').className=c.icono||'';document.getElementById('modalTitle').textContent='Editar Categoria';document.getElementById('catModal').classList.add('show');}
function closeModal(){document.getElementById('catModal').classList.remove('show');}
function saveCategoria(){var id=document.getElementById('catId').value,nombre=document.getElementById('catNombre').value.trim();if(!nombre){showAlert('Nombre requerido','error');return;}var p=new URLSearchParams({nombre:nombre,icono:document.getElementById('catIcono').value.trim(),descripcion:document.getElementById('catDesc').value.trim()});fetch(id?'api/categorias/'+id:'api/categorias',{method:id?'PUT':'POST',body:p}).then(function(r){return r.json();}).then(function(j){if(j.success){showAlert(id?'Actualizada':'Creada','success');closeModal();load();}else{showAlert(j.message||'Error','error');}}).catch(function(e){showAlert('Error: '+e.message,'error');});}
function askDel(id,n){delId=id;document.getElementById('delNombre').textContent=n;document.getElementById('delModal').classList.add('show');}
function confirmDelete(){if(!delId)return;fetch('api/categorias/'+delId,{method:'DELETE'}).then(function(r){return r.json();}).then(function(j){if(j.success){showAlert('Eliminada','success');document.getElementById('delModal').classList.remove('show');delId=null;load();}else{showAlert(j.message||'Error','error');}}).catch(function(e){showAlert('Error: '+e.message,'error');});}
function showAlert(msg,type){var d=document.createElement('div');d.className='alert alert-'+(type==='error'?'error':'success');d.innerHTML='<i class="fas fa-'+(type==='error'?'exclamation-circle':'check-circle')+'"></i> '+msg;document.getElementById('alert-container').appendChild(d);setTimeout(function(){d.remove();},4000);}
document.addEventListener('DOMContentLoaded',load);
</script></body></html>