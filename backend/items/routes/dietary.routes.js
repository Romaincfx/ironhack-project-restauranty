const express = require('express');
const router = express.Router();

const Dietary = require('../models/dietary.model')

const upload = require('../config/cloudinary.config');

router.get("/", (req, res) => {

    Dietary.find().then(dietary => {
        res.json(dietary)
    }).catch(err => {
        res.status(400).json(err)
    })

})

router.get("/:id", (req, res) => {

    const id = req.params.id

    Dietary.findById(id).then(dietary => {
        res.json(dietary)
    }).catch(err => {
        res.status(400).json(err)
    })

})

router.post("/", upload.single("imagem"), async (req, res) => {
    try {
        // 1) start with everything sent in the body
        const dietaryData = { ...req.body };

        // 2) if a file was uploaded, push its Cloudinary URL onto dietaryData.image
        if (req.file) {
            dietaryData.image = [req.file.path]; // Cloudinary automatically provides the URL in req.file.path
        }

        // 3) create the new Dietary document
        const newDietary = await Dietary.create(dietaryData);

        // 4) respond with the freshly created doc
        res.status(201).json(newDietary);

    } catch (err) {
        console.error("Failed to create Dietary:", err);
        res.status(400).json({ error: err.message });
    }
});

router.put("/:id", (req, res) => {

    const dietary = req.body

    Dietary.findByIdAndUpdate(dietary._id, dietary, { new: true }).then(newDietary => {
        res.json(newDietary)
    }).catch(err => {
        res.status(400).json(err)
    })
})

router.delete("/:id", (req, res) => {

    const id = req.params.id

    Dietary.findByIdAndDelete(id).then(dietaryDeleted => {
        res.json({
            message: "Dietary Eliminados",
            dietaryDeleted
        })
    }).catch(err => {
        res.status(400).json(err)
    })

})

module.exports = router;
