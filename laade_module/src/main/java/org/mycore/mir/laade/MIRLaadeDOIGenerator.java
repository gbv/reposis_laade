package org.mycore.mir.laade;

import org.jdom2.Element;
import org.mycore.datamodel.metadata.MCRBase;
import org.mycore.datamodel.metadata.MCRObject;
import org.mycore.mods.MCRMODSWrapper;
import org.mycore.pi.MCRPIGenerator;
import org.mycore.pi.doi.MCRDOIParser;
import org.mycore.pi.doi.MCRDigitalObjectIdentifier;
import org.mycore.pi.exceptions.MCRPersistentIdentifierException;

public class MIRLaadeDOIGenerator extends MCRPIGenerator<MCRDigitalObjectIdentifier> {

    public MIRLaadeDOIGenerator(String generatorID) {
        super(generatorID);
    }

    @Override
    public MCRDigitalObjectIdentifier generate(MCRBase mcrBase, String additional)
        throws MCRPersistentIdentifierException {

        final MCRMODSWrapper mcrmodsWrapper = new MCRMODSWrapper((MCRObject) mcrBase);
        final Element shelfLocator = mcrmodsWrapper.getElement("mods:location/mods:shelfLocator");

        if (shelfLocator == null) {
            throw new MCRPersistentIdentifierException("Error reading signature from " + mcrBase.getId());
        }

        final String signature = shelfLocator.getText();
        if (signature == null) {
            throw new MCRPersistentIdentifierException("Error reading signature from " + mcrBase.getId());
        }

        final MCRDigitalObjectIdentifier newDOI = new MCRDOIParser()
            .parse("10.25362/laade.".concat(signature)).get();

        return newDOI;
    }
}
