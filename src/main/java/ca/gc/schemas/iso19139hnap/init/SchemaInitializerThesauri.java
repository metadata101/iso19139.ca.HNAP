package ca.gc.schemas.iso19139hnap.init;

import org.fao.geonet.constants.Geonet;
import org.fao.geonet.domain.Setting;
import org.fao.geonet.domain.SettingDataType;
import org.fao.geonet.kernel.GeonetworkDataDirectory;
import org.fao.geonet.kernel.setting.SettingManager;
import org.fao.geonet.repository.SettingRepository;
import org.fao.geonet.utils.Log;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationListener;
import org.springframework.core.Ordered;
import org.springframework.core.io.Resource;
import org.springframework.core.io.support.PathMatchingResourcePatternResolver;

import javax.annotation.PostConstruct;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.sql.SQLException;
import java.util.regex.Pattern;

/**
 * This class is for setting up a schema.
 * <p>
 * It watches the system startup and gives us the opportunity to do any setup required at the appropriate time.
 * <p>
 * See config-spring-geonetwork.xml in this schema
 */
public class SchemaInitializerThesauri implements
    ApplicationListener<GeonetworkDataDirectory.GeonetworkDataDirectoryInitializedEvent>,
    Ordered {

    boolean OVERWRITE_EXISTING_THESAURI = true;

    @PostConstruct
    public void init()
    {
    }


    private static String resourceTypeDir = "external"; // "local" or "external"
    private static String jarRDFPattern = "thesarus/**/*.rdf"; //find rdf files in the JAR

    // for each of the RDF files included in this JAR, if its not in the corresponding location in datadir, then we copy it in
    public void ConfigureThesauruses(Path thesauriDir) throws IOException {
        PathMatchingResourcePatternResolver resolver =
            new PathMatchingResourcePatternResolver(Thread.currentThread().getContextClassLoader());
        //for each of the .rdf files
        for (Resource r : resolver.getResources(jarRDFPattern)) {
            String fname = r.getFilename(); //i.e. thesaurus/theme/EC_ISO_Countries.rdf
            String[] subDirs = r.getURI().toURL().getPath().split(Pattern.quote("/"));
            String dir = subDirs[subDirs.length - 2]; // ie. "theme"
            ///put in - WEB-INF/data/config/codelist/external/thesauri/theme/EC_ISO_Countries.rdf
            //ensure that dirs exist
            Files.createDirectories(Paths.get(thesauriDir.toString(), resourceTypeDir, "thesauri", dir));
            //full path to put the .rdf
            Path correspondingDataDirFile = Paths.get(thesauriDir.toString(), resourceTypeDir, "thesauri", dir, fname);
            if (!Files.exists(correspondingDataDirFile) || OVERWRITE_EXISTING_THESAURI) {
                if (Files.exists(correspondingDataDirFile))
                    Files.delete(correspondingDataDirFile);
                //need to copy it in...
                Log.info(Geonet.THESAURUS, "ISO19139.HNAP: SchemaInitializer: need to copy in Thesaurus: " + fname);
                try (InputStream is = r.getInputStream()) { //auto close
                    java.nio.file.Files.copy(is, correspondingDataDirFile);
                }
            }
        }
    }


    //when the data dir is configured, we're good to copy in our thesauruses
    @Override
    public void onApplicationEvent(GeonetworkDataDirectory.GeonetworkDataDirectoryInitializedEvent event) {
        Path thesauriDir = event.getSource().getThesauriDir();
        try {
            ConfigureThesauruses(thesauriDir);
        } catch (IOException e) {
            Log.error(Geonet.THESAURUS, "SchemaInitializer: preloading RDF files", e);
        }
    }

    @Override
    public int getOrder() {
        return 1;
    }
}
