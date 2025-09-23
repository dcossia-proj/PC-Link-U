<template>
  <nav class="navbar navbar-light navbar-expand-lg navbar-background header">
    <div class="container">
      <a class="navbar-brand" href="./" title="PC Link U">
        <img src="/images/logo-apollo-45.png" height="45" alt="PC Link U">
      </a>
      <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarSupportedContent"
              aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation">
        <span class="navbar-toggler-icon"></span>
      </button>
      <div class="collapse navbar-collapse" id="navbarSupportedContent">
        <ul class="navbar-nav me-auto mb-2 mb-lg-0">
          <li class="nav-item">
            <a class="nav-link" href="./"><i class="fas fa-fw fa-home"></i> {{ $t('navbar.home') }}</a>
          </li>
          <li class="nav-item">
            <a class="nav-link" href="./pin"><i class="fas fa-fw fa-unlock"></i> {{ $t('navbar.pin') }}</a>
          </li>
          <li class="nav-item">
            <a class="nav-link" href="./apps"><i class="fas fa-fw fa-stream"></i> {{ $t('navbar.applications') }}</a>
          </li>
          <li class="nav-item">
            <a class="nav-link" href="./config"><i class="fas fa-fw fa-cog"></i> {{ $t('navbar.configuration') }}</a>
          </li>
          <li class="nav-item">
            <a class="nav-link" href="./password"><i class="fas fa-fw fa-user-shield"></i> {{ $t('navbar.password') }}</a>
          </li>
          <li class="nav-item">
            <a class="nav-link" href="./troubleshooting"><i class="fas fa-fw fa-info"></i> {{ $t('navbar.troubleshoot') }}</a>
          </li>
          <li class="nav-item">
            <ThemeToggle/>
          </li>
        </ul>
      </div>
    </div>
  </nav>
</template>

<script>
import ThemeToggle from './ThemeToggle.vue'

export default {
  components: { ThemeToggle },
  created() {
    console.log("Header mounted!")
  },
  mounted() {
    let el = document.querySelector("a[href='" + document.location.pathname + "']");
    if (el) el.classList.add("active")
  }
}
</script>

<style>
.navbar-background {
  background-color: #1b2838
}

.header .nav-link {
  color: rgba(199, 213, 224, .75) !important;
}

.header .nav-link.active {
  color: #66c0f4 !important;
  font-weight: 500;
}

.header .nav-link:hover {
  color: #66c0f4 !important;
  font-weight: 500;
}

.header .navbar-toggler {
  color: rgba(199, 213, 224, .65) !important;
  border: var(--bs-border-width) solid rgba(199, 213, 224, 0.15) !important;
}

.header .navbar-toggler-icon {
  --bs-navbar-toggler-icon-bg: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 30 30'%3e%3cpath stroke='rgba%28199, 213, 224, 0.75%29' stroke-linecap='round' stroke-miterlimit='10' stroke-width='2' d='M4 7h22M4 15h22M4 23h22'/%3e%3c/svg%3e") !important;
}

.form-control::placeholder {
  opacity: 0.5;
}
</style>
