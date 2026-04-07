<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
    import="com.hiper.inventory.dao.UserDAO, com.hiper.inventory.models.User, com.hiper.inventory.utils.DatabaseUtil, java.util.Date"%>
<%
    String username = request.getParameter("username");
    String password = request.getParameter("password");
    String remember = request.getParameter("remember");

    if (username == null || username.isEmpty() || password == null || password.isEmpty()) {
        response.sendRedirect("index.jsp?error=required");
        return;
    }

    UserDAO userDAO = new UserDAO();
    User user = userDAO.authenticate(username, password);

    if (user != null && user.isActivo()) {
        session.setAttribute("userId", user.getId());
        session.setAttribute("username", user.getUsername());
        session.setAttribute("userRole", user.getRol());
        session.setAttribute("userName", user.getNombre());
        session.setAttribute("userDept", user.getDepartamento());
        session.setMaxInactiveInterval(30 * 60);

        user.setUltimoAcceso(new Date());
        userDAO.updateUser(user);
        DatabaseUtil.logAction(user.getId(), "LOGIN", "auth", 0, null, "Inicio de sesion");

        if ("on".equals(remember)) {
            javax.servlet.http.Cookie cookie = new javax.servlet.http.Cookie("rememberMe", username);
            cookie.setMaxAge(7 * 24 * 60 * 60);
            response.addCookie(cookie);
        }
        response.sendRedirect("inicio.jsp");
    } else {
        response.sendRedirect("index.jsp?error=invalid");
    }
%>
