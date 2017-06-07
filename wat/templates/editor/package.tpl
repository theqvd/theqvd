<li class="js-installed-package installed-package" style="position: relative;" data-package="<%= package %>">
    <a class="button2 button-icon fa fa-trash js-delete-package-btn" data-package="<%= package %>"></a>
    <%= package %>
    <div class="js-package-buttonset package-buttonset <%= configVisible ? '' : 'hidden' %>" style="position: absolute; top: 0; right: 0;" data-package="<%= package %>">
        <a class="fright button2 button-icon fa fa-arrow-circle-down js-order-package-down order-package-down" data-package="<%= package %>"></a>
        <a class="fright button2 button-icon fa fa-arrow-circle-up js-order-package-up order-package-up" data-package="<%= package %>"></a>
    </div>
</li>
