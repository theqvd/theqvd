<div class="welcome-message">
    <span class="welcome" data-i18n="Welcome to QVD's Web Administration Tool"></span>
</div>

<div class="home-wrapper">
    <div class="home-row">
        <% if (Wat.C.checkACL('vm.stats.running-vms')) { %>
        <div class="home-cell">
            <div class="home-title" data-i18n>Running virtual machines</div>
            <div class="home-percent-wrapper">
                <div class="js-running-vms-percent home-title home-percent js-home-percent"></div>
                <div id="running-vms" class="pie-chart js-pie-chart" data-target="vms" width="200px" height="200px"></div>
            </div>
            <%= Wat.C.ifACL('<a href="#/vms">', 'vm.see-main.') %>
                <div class="js-running-vms-data home-title"></div>
            <%= Wat.C.ifACL('</a>', 'vm.see-main.') %>
        </div>
        <% } %>


        <div class="home-cell">
            <div class="home-title" data-i18n>Summary</div>
            <table class="summary-table">
                <% if (Wat.C.checkACL('user.stats.summary')) { %>
                <tr>
                    <td class="max-1-icons">
                        <i class="<%= CLASS_ICON_USERS %>"></i>
                    </td>                    
                    <td>
                        <%= Wat.C.ifACL('<a href="#/users" data-i18n="Users">', 'user.see-main.') %>
                            <%= i18n.t('Users') %>
                        <%= Wat.C.ifACL('</a>', 'user.see-main.') %>
                    </td>
                    <td>
                        <span class="summary-data js-summary-users"><%= stats.User.total %></span>
                    </td>
                </tr>
                <% } if (Wat.C.checkACL('vm.stats.summary')) { %>
                <tr>    
                    <td class="max-1-icons">
                        <i class="<%= CLASS_ICON_VMS %>"></i>
                    </td>        
                    <td>
                        <%= Wat.C.ifACL('<a href="#/vms" data-i18n="Virtual machines">', 'vm.see-main.') %>
                            <%= i18n.t('Virtual machines') %>
                        <%= Wat.C.ifACL('</a>', 'vm.see-main.') %>
                    </td>
                    <td>
                        <span class="summary-data js-summary-vms"><%= stats.VM.total %></span>
                    </td>
                </tr>
                <% } if (Wat.C.checkACL('host.stats.summary')) { %>
                <tr>
                    <td class="max-1-icons">
                        <i class="<%= CLASS_ICON_HOSTS %>"></i>
                    </td>       
                    <td>
                        <%= Wat.C.ifACL('<a href="#/hosts" data-i18n="Nodes">', 'host.see-main.') %>
                            <%= i18n.t('Nodes') %>
                        <%= Wat.C.ifACL('</a>', 'host.see-main.') %>
                    </td>
                    <td>
                        <span class="summary-data js-summary-hosts"><%= stats.Host.total %></span>
                    </td>
                </tr>
                <% } if (Wat.C.checkACL('osf.stats.summary')) { %>
                <tr>
                    <td class="max-1-icons">
                        <i class="<%= CLASS_ICON_OSFS %>"></i>
                    </td>   
                    <td>
                        <%= Wat.C.ifACL('<a href="#/osfs" data-i18n="OS Flavours">', 'osf.see-main.') %>
                            <%= i18n.t('OS Flavours') %>
                        <%= Wat.C.ifACL('</a>', 'osf.see-main.') %>
                    </td>
                    <td>
                        <span class="summary-data js-summary-osfs"><%= stats.OSF.total %></span>
                    </td>
                </tr>
                <% } if (Wat.C.checkACL('di.stats.summary')) { %>
                <tr>
                    <td class="max-1-icons">
                        <i class="<%= CLASS_ICON_DIS %>"></i>
                    </td>                
                    <td>
                        <%= Wat.C.ifACL('<a href="#/dis" data-i18n="Disk images">', 'di.see-main.') %>
                            <%= i18n.t('Disk images') %>
                        <%= Wat.C.ifACL('</a>', 'di.see-main.') %>
                    </td>
                    <td>
                        <span class="summary-data js-summary-dis"><%= stats.DI.total %></span>
                    </td>
                </tr>
                <% } %>
            </table>
            <table id="summary">
            </table>
        </div>
        
        <% if (Wat.C.checkACL('host.stats.running-hosts')) { %>
        <div class="home-cell">
            <div class="home-title" data-i18n>Running nodes</div>
            <div class="home-percent-wrapper">
                <div class="js-running-hosts-percent home-title home-percent js-home-percent"></div>
                <div id="running-hosts" class="pie-chart js-pie-chart" data-target="hosts" width="200px" height="200px"></div>
            </div>
            <%= Wat.C.ifACL('<a href="#/hosts">', 'host.see-main.') %>
                <div class="js-running-hosts-data home-title"></div>
            <%= Wat.C.ifACL('</a>', 'host.see-main.') %>
        </div>
        <% } %>
    </div>
</div>
<div class="home-wrapper">
    <div class="home-row">
        <% if (Wat.C.checkACL('vm.stats.close-to-expire')) { %>
        <div class="home-cell">
            <div class="home-title" data-i18n>VMs close to expire</div>
            <%
                if (stats.VM.expiration.length == 0) {
            %>
                <div class="no-elements" data-18n>There are not VMS close to expire</div>
            <%
                }
                else {
            %>
                    <table class="summary-table">
                    <% 
                        $.each(stats.VM.expiration, function (iExp, exp) {
                            var priorityClass = '';
                            var remainingTime = '';
                            var remainingTimeAttr = '';
                            if (exp.remaining_time.days < 1) {
                                priorityClass = 'error';
                                remainingTime = exp.remaining_time.hours + ':' + exp.remaining_time.minutes + ':' + exp.remaining_time.seconds;
                            }
                            else if(exp.remaining_time.days < 7) {
                                priorityClass = 'warning';
                                remainingTimeAttr = 'data-days="' + exp.remaining_time.days + '"';
                            }
                            else {
                                priorityClass = 'ok';
                                remainingTimeAttr = 'data-days="+7"';
                            }                    
                            %>
                            <tr>
                                <td class="max-1-icons">
                                    <i class="fa fa-warning <%= priorityClass %>"></i>
                                </td>                    
                                <td>
                                    <%= Wat.C.ifACL('<a href="#/vm/' + exp.id + '">', 'vm.see-details.') %>
                                        <%= exp.name %>
                                    <%= Wat.C.ifACL('</a>', 'vm.see-details.') %>
                                </td>
                                <td>
                                    <span class="summary-data js-summary-users" <%= remainingTimeAttr %>><%= remainingTime %></span>
                                </td>
                            </tr>
                            <%
                        }); 
                    %>
                    </table>
                    
                <%
                    }
                %>
        </div>
        <% } if (Wat.C.checkACL('host.stats.top-hosts.most.vms')) { %>
        <div class="home-cell">
            <div class="home-title" data-i18n>Nodes with most running VMs</div>
            <div id="hosts-more-vms" class="bar-chart js-bar-chart" style="width:95%;height:200px;"></div>
        </div>
        <% } %>
        <div class="home-cell">
            <div class="home-title" data-i18n>Blocked elements</div>
            <table class="summary-table">
                <% if (Wat.C.checkACL('user.stats.blocked')) { %>
                <tr>
                    <td class="max-1-icons">
                        <i class="<%= CLASS_ICON_USERS %>"></i>
                    </td>                    
                    <td>
                        <%= Wat.C.ifACL('<a href="#/users" data-i18n="Users">', 'user.see-main.') %>
                            <%= i18n.t('Users') %>
                        <%= Wat.C.ifACL('</a>', 'user.see-main.') %>
                    </td>
                    <td>
                        <span class="summary-data js-summary-blocked-users"><%= stats.User.blocked %></span>
                    </td>
                </tr>
                <% } if (Wat.C.checkACL('vm.stats.blocked')) { %>
                <tr>    
                    <td class="max-1-icons">
                        <i class="<%= CLASS_ICON_VMS %>"></i>
                    </td>        
                    <td>
                        <%= Wat.C.ifACL('<a href="#/vms" data-i18n="Virtual machines">', 'vm.see-main.') %>
                            <%= i18n.t('Virtual machines') %>
                        <%= Wat.C.ifACL('</a>', 'vm.see-main.') %>
                    </td>
                    <td>
                        <span class="summary-data js-summary-blocked-vms"><%= stats.VM.blocked %></span>
                    </td>
                </tr>
                <% } if (Wat.C.checkACL('host.stats.blocked')) { %>
                <tr>
                    <td class="max-1-icons">
                        <i class="<%= CLASS_ICON_HOSTS %>"></i>
                    </td>       
                    <td>
                        <%= Wat.C.ifACL('<a href="#/hosts" data-i18n="Nodes">', 'host.see-main.') %>
                            <%= i18n.t('Nodes') %>
                        <%= Wat.C.ifACL('</a>', 'host.see-main.') %>
                    </td>
                    <td>
                        <span class="summary-data js-summary-blocked-hosts"><%= stats.Host.blocked %></span>
                    </td>
                </tr>
                <% } if (Wat.C.checkACL('di.stats.blocked')) { %>
                <tr>
                    <td class="max-1-icons">
                        <i class="<%= CLASS_ICON_DIS %>"></i>
                    </td>                
                    <td>
                        <%= Wat.C.ifACL('<a href="#/dis" data-i18n="Disk images">', 'di.see-main.') %>
                            <%= i18n.t('Disk images') %>
                        <%= Wat.C.ifACL('</a>', 'di.see-main.') %>
                    </td>
                    <td>
                        <span class="summary-data js-summary-blocked-dis"><%= stats.DI.blocked %></span>
                    </td>
                </tr>
                <% } %>
            </table>
        </div>
    </div>
</div>