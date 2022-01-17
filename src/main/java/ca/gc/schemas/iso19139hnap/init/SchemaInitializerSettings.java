package ca.gc.schemas.iso19139hnap.init;

import ca.gc.schema.iso19139hnap.util.XslUtilHnap;
import org.fao.geonet.domain.Setting;
import org.fao.geonet.domain.SettingDataType;
import org.fao.geonet.events.server.ServerStartup;
import org.fao.geonet.kernel.GeonetworkDataDirectory;
import org.fao.geonet.repository.SettingRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationEvent;
import org.springframework.context.ApplicationListener;

import javax.annotation.PostConstruct;


/**
 * Creates Settings in the Settings table
 * With a default value
 */
public class SchemaInitializerSettings implements
    ApplicationListener<ServerStartup> {

    final private static String HNAP_SCHEMA_NAME = "iso19139.ca.HNAP";


    @Autowired
    private SettingRepository _settingRepository;

    @PostConstruct
    public void init() {
    }

    private void addSetting(String key,SettingDataType type, String value, int position ) {
        if (!_settingRepository.findById(key).isPresent()) {
            Setting setting = new Setting();
            setting.setDataType(type);
            setting.setName(key);
            setting.setPosition(position);
            setting.setValue(value);
            _settingRepository.save(setting);
        }
    }

    private void addSettings() {
        addSetting("schema/"+ HNAP_SCHEMA_NAME+"/UseGovernmentOfCanadaOrganisationName",
            SettingDataType.BOOLEAN,"true",1);
        addSetting("schema/"+ HNAP_SCHEMA_NAME+"/DefaultMainOrganizationName_en",
            SettingDataType.STRING,"Government of Canada",2);
        addSetting("schema/"+ HNAP_SCHEMA_NAME+"/DefaultMainOrganizationName_fr",
            SettingDataType.STRING,"Gouvernement du Canada",3);
    }

    //when the server starts up, we are ready to
    @Override
    public void onApplicationEvent(ServerStartup event) {
        addSettings();
    }
}
