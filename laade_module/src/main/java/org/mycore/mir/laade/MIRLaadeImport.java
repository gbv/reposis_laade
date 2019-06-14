package org.mycore.mir.laade;

import java.io.IOException;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.attribute.BasicFileAttributes;
import java.text.NumberFormat;
import java.time.Instant;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Comparator;
import java.util.List;
import java.util.Locale;
import java.util.Objects;
import java.util.concurrent.ExecutionException;
import java.util.stream.Collectors;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.jdom2.Document;
import org.jdom2.Element;
import org.jdom2.JDOMException;
import org.jdom2.Namespace;
import org.mycore.access.MCRAccessException;
import org.mycore.access.MCRAccessInterface;
import org.mycore.access.MCRAccessManager;
import org.mycore.common.MCRException;
import org.mycore.common.MCRPersistenceException;
import org.mycore.common.config.MCRConfiguration;
import org.mycore.common.content.MCRContent;
import org.mycore.common.content.MCRURLContent;
import org.mycore.common.content.transformer.MCRXSLTransformer;
import org.mycore.datamodel.classifications2.MCRCategoryID;
import org.mycore.datamodel.common.MCRActiveLinkException;
import org.mycore.datamodel.metadata.MCRBase;
import org.mycore.datamodel.metadata.MCRDerivate;
import org.mycore.datamodel.metadata.MCRMetaIFS;
import org.mycore.datamodel.metadata.MCRMetaLinkID;
import org.mycore.datamodel.metadata.MCRMetadataManager;
import org.mycore.datamodel.metadata.MCRObject;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.datamodel.niofs.MCRPath;
import org.mycore.datamodel.niofs.utils.MCRFileCollectingFileVisitor;
import org.mycore.frontend.cli.annotation.MCRCommand;
import org.mycore.frontend.cli.annotation.MCRCommandGroup;
import org.mycore.mods.MCRMODSWrapper;
import org.mycore.pi.MCRPIService;
import org.mycore.pi.MCRPIServiceManager;
import org.mycore.pi.MCRPersistentIdentifier;
import org.mycore.pi.exceptions.MCRPersistentIdentifierException;
import org.xml.sax.SAXException;

@MCRCommandGroup(
    name = "MIRLaadeImport")
public class MIRLaadeImport {

    private static final Logger LOGGER = LogManager.getLogger();

    private static final String SRU_URL_TEMPLATE = "http://sru.gbv.de/opac-de-hil8?version=1.1&operation=searchRetrieve&query=pica.sgs=\"$SIGNATURE$\"&maximumRecords=1&recordSchema=picaxml";

    private static final Namespace ZS_NAMESPACE = Namespace.getNamespace("zs", "http://www.loc.gov/zing/srw/");

    @MCRCommand(syntax = "import laade object {0} with online folder {1}")
    public static void importLadaObject(String signature, String onlineFolder) throws MalformedURLException {
        final MCRXSLTransformer transformer = new MCRXSLTransformer("xsl/LadePica2mods.xsl");
        transformer.setTransformerFactory("net.sf.saxon.TransformerFactoryImpl");
        String generatedMcrIdString = generateMyCoReID(signature);

        try {
            final String encodedSignature = URLEncoder.encode(signature, "UTF-8");
            final String picaURL = SRU_URL_TEMPLATE.replace("$SIGNATURE$", encodedSignature);
            final MCRURLContent pica = new MCRURLContent(new URL(picaURL));
            final Document picaDocument = pica.asXML();
            int numberOfRecords = getNumberOfRecords(picaDocument);

            if (numberOfRecords == 1) {
                final MCRContent resultingMods = transformer.transform(pica);
                final Document modsDocument = resultingMods.asXML();
                final MCRObject mcrObject = MCRMODSWrapper.wrapMODSDocument(modsDocument.getRootElement(), "laade");

                addPublicationDateFromFiles(signature, onlineFolder, mcrObject);

                mcrObject.getService().setState(new MCRCategoryID("state","published"));
                MCRObjectID generatedMCRId = MCRObjectID.getInstance(generatedMcrIdString);
                mcrObject.setId(generatedMCRId);
                if (MCRMetadataManager.exists(generatedMCRId)) {
                    MCRMetadataManager.update(mcrObject);
                } else {
                    MCRMetadataManager.create(mcrObject);
                    importFile(onlineFolder, generatedMcrIdString);
                }
            } else if (numberOfRecords == 0) {
                LOGGER.info("No object found for signature: " + signature);
            } else {
                LOGGER.error("Could not get a distinct result for signature: " + signature);
            }
        } catch (IOException e) {
            throw new MCRException("Error while transforming PICA!", e);
        } catch (JDOMException | SAXException e) {
            throw new MCRException("Error while creating JDOM!", e);
        } catch (MCRAccessException e) {
            throw new MCRException("Error while creating MCRObject!", e);
        }
    }

    private static void addPublicationDateFromFiles(String signature, String onlineFolder, MCRObject mcrObject)
        throws IOException {
        String[] parts = signature.split(" ");
        if (parts.length != 3) {
            throw new MCRException("Invalid Signature!");
        }
        int fromNumber = Integer.parseInt(parts[2].split("-")[0]);

        double base = Math.floor((double) Math.abs(fromNumber - 1) / 1000.0);
        NumberFormat format = NumberFormat.getIntegerInstance(Locale.ROOT);
        format.setGroupingUsed(false);

        String folder;
        if (parts[1].equals("CD")) {
            format.setMinimumIntegerDigits(4);
            folder = "CD_" + format.format(base * 1000 + 1) + "_" + format.format((base + 1) * 1000);
        } else {
            format.setMinimumIntegerDigits(5);
            folder = format.format(base * 1000 + 1) + "_" + format.format((base + 1) * 1000);
        }
        final Path onlineFolderPath = Paths.get(onlineFolder);
        final Path contentPath = onlineFolderPath.resolve(folder).resolve(mapSignature(signature));
        if (Files.exists(contentPath) && Files.isDirectory(contentPath)) {
            BasicFileAttributes attr = Files.readAttributes(contentPath, BasicFileAttributes.class);
            final String publicationYear = DateTimeFormatter.ofPattern("yyyy")
                .format(Instant.ofEpochMilli(attr.creationTime().toMillis()).atZone(ZoneId.of("UTC")));
            new MCRMODSWrapper(mcrObject)
                .getElement("mods:originInfo[@eventType='publication']/mods:dateIssued[@encoding='w3cdtf']")
                .setText(publicationYear);
        }
    }

    private static int getNumberOfRecords(final Document responseDoc) {
        Element response = responseDoc.getRootElement();
        Element numberOfRecordsElement = response.getChild("numberOfRecords", ZS_NAMESPACE);
        return Integer.parseInt(numberOfRecordsElement.getTextTrim(), 10);
    }

    private static String generateMyCoReID(final String signature) {
        String generatedMcrId = signature;
        if (signature.contains("-")) {
            generatedMcrId = generatedMcrId.split("-")[0];
        }
        String[] s = generatedMcrId.split(" ");
        if (s.length < 3) {
            throw new MCRException("The id seems invalid! " + signature);
        }
        String projectAppend = s[1];
        String numberPart = s[2];
        int number = Integer.parseInt(numberPart, 10);
        NumberFormat format = NumberFormat.getIntegerInstance(Locale.ROOT);
        format.setGroupingUsed(false);
        format.setMinimumIntegerDigits(8);
        return "laade" + projectAppend + "_mods_" + format.format(number);
    }

    @MCRCommand(syntax = "import file for laade object {1} from online folder {0}")
    public static void importFile(String onlineFolder, String mycoreIDString) throws IOException, MCRAccessException {
        final MCRObjectID mycoreID = MCRObjectID.getInstance(mycoreIDString);

        final Path onlineFolderPath = Paths.get(onlineFolder);
        if (!Files.exists(onlineFolderPath)) {
            throw new IOException("The Path " + onlineFolder + " does not exist!");
        }

        if (!MCRMetadataManager.exists(mycoreID)) {
            throw new IOException("The MyCoRe-Object " + mycoreIDString + " does not exist!");
        }

        final MCRMODSWrapper wrapper = new MCRMODSWrapper(MCRMetadataManager.retrieveMCRObject(mycoreID));
        final String signatur = wrapper.getElementValue("mods:location/mods:shelfLocator");

        if (signatur == null || signatur.isEmpty()) {
            LOGGER.info("No signature for object " + mycoreIDString);
            return;
        }

        String[] parts = signatur.split("_");
        if(parts.length!=3){
            throw new MCRException("Invalid Signature!");
        }
        int fromNumber = Integer.parseInt(parts[2].split("-")[0]);

        double base = Math.floor((double) Math.abs(fromNumber-1) / 1000.0);
        NumberFormat format = NumberFormat.getIntegerInstance(Locale.ROOT);
        format.setGroupingUsed(false);

        String folder;
        if(parts[1].equals("CD")){
            format.setMinimumIntegerDigits(4);
            folder= "CD_" + format.format(base * 1000 + 1) + "_" + format.format((base + 1) * 1000);
        } else {
            format.setMinimumIntegerDigits(5);
            folder= format.format(base * 1000 + 1) + "_" + format.format((base + 1) * 1000);
        }

        final Path contentPath = onlineFolderPath.resolve(folder).resolve(mapSignature(signatur));

        LOGGER.info("Search for files in {}", contentPath.toString());
        final MCRFileCollectingFileVisitor<Path> collector = new MCRFileCollectingFileVisitor<Path>();
        Files.walkFileTree(contentPath, collector);
        final ArrayList<Path> files = collector.getPaths();

        final List<Path> imageFiles = files.stream().filter(p -> p.toString().endsWith(".jpg"))
            .collect(Collectors.toList());
        if (imageFiles.size() > 0) {

            Path firstImage = imageFiles.stream().min(Comparator.comparing(Objects::toString, String::compareTo)).get();
            final MCRDerivate images = createDerivate(mycoreIDString, "cover",
                contentPath.relativize(
                    firstImage).toString());
            final MCRObjectID id = images.getId();
            imageFiles.forEach(imagePath -> {
                final Path fileName = contentPath.relativize(imagePath);
                final MCRPath filePath = MCRPath.getPath(id.toString(), fileName.toString());
                LOGGER.info("Import {}", fileName);

                try {
                    Files.copy(imagePath, filePath);
                } catch (IOException e) {
                    throw new MCRException("Error while copying", e);
                }
            });
        }

        final List<Path> mp3Files = files.stream().filter(p -> p.toString().endsWith(".mp3"))
            .collect(Collectors.toList());
        if (mp3Files.size() > 0) {
            Path firstMP3 = mp3Files.stream().min(Comparator.comparing(Objects::toString, String::compareTo)).get();
            final MCRDerivate images = createDerivate(mycoreIDString, "sound", contentPath.relativize(firstMP3).toString());
            final MCRObjectID id = images.getId();
            mp3Files.forEach(mp3Path -> {
                final Path fileName = contentPath.relativize(mp3Path);
                final MCRPath filePath = MCRPath.getPath(id.toString(), fileName.toString());
                LOGGER.info("Import {}", fileName);
                try {
                    Files.copy(mp3Path, filePath);
                } catch (IOException e) {
                    throw new MCRException("Error while copying", e);
                }
            });
        }
    }

    @MCRCommand(syntax = "create doi for object {0}")
    public static void createDOIForObjectIfNotExist(String objectIDString)
        throws MCRAccessException, ExecutionException, MCRActiveLinkException, MCRPersistentIdentifierException,
        InterruptedException {
        final MCRObjectID objectID = MCRObjectID.getInstance(objectIDString);

        if (!MCRMetadataManager.exists(objectID)) {
            LOGGER.error("Object {} does not exist!", objectID);
            return;
        }

        MCRPIService<MCRPersistentIdentifier> registrationService = MCRPIServiceManager
            .getInstance().getRegistrationService("Datacite");

        if (registrationService.isCreated(objectID, "")) {
            LOGGER.info("Object {} already has a DOI!", objectID);
        }
        final MCRBase object = MCRMetadataManager.retrieve(objectID);
        final MCRPersistentIdentifier doi = registrationService.register(object, "");
        LOGGER.info("Registered doi: {} for object {}", doi.asString(), objectID);
    }

    private static String mapSignature(String old) {
        return old.replace('-', '_').replace(' ', '_');
    }

    public static MCRDerivate createDerivate(String documentID, String label, String mainFile)
        throws MCRPersistenceException, IOException, MCRAccessException {
        final String projectId = MCRObjectID.getInstance(documentID).getProjectId();
        MCRObjectID oid = MCRObjectID.getNextFreeId(projectId, "derivate");
        final String derivateID = oid.toString();

        MCRDerivate derivate = new MCRDerivate();
        derivate.setId(oid);
        derivate.setLabel(label);

        String schema = MCRConfiguration.instance().getString("MCR.Metadata.Config.derivate", "datamodel-derivate.xml")
            .replaceAll(".xml",
                ".xsd");
        derivate.setSchema(schema);

        MCRMetaLinkID linkId = new MCRMetaLinkID();
        linkId.setSubTag("linkmeta");
        linkId.setReference(documentID, null, null);
        derivate.getDerivate().setLinkMeta(linkId);

        MCRMetaIFS ifs = new MCRMetaIFS();
        ifs.setSubTag("internal");
        ifs.setSourcePath(null);
        ifs.setMainDoc(mainFile);

        derivate.getDerivate().setInternals(ifs);

        LOGGER.debug("Creating new derivate with ID {}", derivateID);
        MCRMetadataManager.create(derivate);

        if (MCRConfiguration.instance().getBoolean("MCR.Access.AddDerivateDefaultRule", true)) {
            MCRAccessInterface AI = MCRAccessManager.getAccessImpl();
            Collection<String> configuredPermissions = AI.getAccessPermissionsFromConfiguration();
            for (String permission : configuredPermissions) {
                MCRAccessManager.addRule(derivateID, permission, MCRAccessManager.getTrueRule(),
                    "default derivate rule");
            }
        }

        final MCRPath rootDir = MCRPath.getPath(derivateID, "/");
        if (Files.notExists(rootDir)) {
            rootDir.getFileSystem().createRoot(derivateID);
        }

        return derivate;
    }

}
