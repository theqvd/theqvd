<div class="welcome-message">
    Welcome to QVD's Web Administration Tool
</div>

<div class="home-wrapper">
    <div class="home-row">
        <div class="home-cell">
            <div class="home-title" data-i18n="">Running nodes</div>
            <div class="home-percent-wrapper">
                <div class="js-running-nodes-percent home-title home-percent js-home-percent"></div>
                <div id="running-nodes" class="pie-chart js-pie-chart" data-target="hosts" width="200px" height="200px"></div>
            </div>
            <a href="#/hosts">
                <div class="js-running-nodes-data home-title"></div>
            </a>
        </div>

        <div class="home-cell">
            <div class="home-title" data-i18n="">Summary</div>
            <table class="summary-table">
                <tr>
                    <td>
                        <a href="#/users" data-i18n="Users">
                            <%= i18n.t('Users') %>
                        </a>
                    </td>
                    <td>
                        <a href="#/users">
                            <i class="<%= CLASS_ICON_USERS %>"></i>
                            x
                            <span class="summary-data js-summary-users">58</span>
                        </a>
                    </td>
                </tr>
                <tr>          
                    <td>
                        <a href="#/vms" data-i18n="Virtual machines">
                            <%= i18n.t('Virtual machines') %>
                        </a>
                    </td>
                    <td>
                        <a href="#/vms">
                            <i class="<%= CLASS_ICON_VMS %>"></i>
                            x
                            <span class="summary-data js-summary-vms">31</span>
                        </a>
                    </td>
                </tr>
                <tr>          
                    <td>
                        <a href="#/hosts" data-i18n="Nodes">
                            <%= i18n.t('Nodes') %>
                        </a>
                    </td>
                    <td>
                        <a href="#/hosts">
                            <i class="<%= CLASS_ICON_NODES %>"></i>
                            x
                            <span class="summary-data js-summary-nodes">3</span>
                        </a>
                    </td>
                </tr>
                <tr>             
                    <td>
                        <a href="#/osfs" data-i18n="OS Flavours">
                            <%= i18n.t('OS Flavours') %>
                        </a>
                    </td>
                    <td>
                        <a href="#/osfs">
                            <i class="<%= CLASS_ICON_OSFS %>"></i>
                            x
                            <span class="summary-data js-summary-osfs">3</span>
                        </a>
                    </td>
                </tr>
                <tr>               
                    <td>
                        <a href="#/dis" data-i18n="Disk images">
                            <%= i18n.t('Disk images') %>
                        </a>
                    </td>
                    <td>
                        <a href="#/dis">
                            <i class="<%= CLASS_ICON_DIS %>"></i>
                            x
                            <span class="summary-data js-summary-dis">14</span>
                        </a>
                    </td>
                </tr>
            </table>
            <table id="summary">
            </table>
        </div>
        
        <div class="home-cell">
            <div class="home-title" data-i18n="">Running virtual machines</div>
            <div class="home-percent-wrapper">
                <div class="js-running-vms-percent home-title home-percent js-home-percent"></div>
                <div id="running-vms" class="pie-chart js-pie-chart" data-target="vms" width="200px" height="200px"></div>
            </div>
            <a href="#/vms">
                <div class="js-running-vms-data home-title"></div>
            </a>
        </div>
    </div>
    <div class="home-row">
        <div class="home-cell">
            
        </div>
        <div class="home-cell">
            <div class="home-title" data-i18n="">Nodes with more running VMs (Top5)</div>
            <div id="nodes-more-vms" style="width:100%;height:200px;"></div>
        </div>
        <div class="home-cell">
            
        </div>
    </div>
    
</div>