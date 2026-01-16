"""Basic tests for gradio_droplet package."""

import pytest
from gradio_droplet import __version__


def test_version():
    """Test that version is defined."""
    assert __version__ == "0.1.0"
